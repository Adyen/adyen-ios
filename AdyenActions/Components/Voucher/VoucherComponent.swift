//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import PassKit
import UIKit

/// A component that handles voucher action.
internal protocol AnyVoucherActionHandler: ActionComponent, Cancellable {
    func handle(_ action: VoucherAction)
}

/// A component that handles voucher action.
public final class VoucherComponent: AnyVoucherActionHandler, ShareableComponent {

    /// The Adyen context.
    public let adyenContext: AdyenContext
    
    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?

    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?

    /// :nodoc:
    public let requiresModalPresentation: Bool = true
    
    /// The voucher component configurations.
    public struct Configuration {
        
        /// The component UI style.
        public var style: VoucherComponentStyle = .init()
        
        /// The localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?
        
        /// Initializes an instance of `Configuration`
        ///
        /// - Parameters:
        ///   - style: The Component UI style.
        ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
        public init(style: VoucherComponentStyle = VoucherComponentStyle(), localizationParameters: LocalizationParameters? = nil) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
    
    /// The voucher component configurations.
    public var configuration: Configuration

    /// :nodoc:
    internal var voucherShareableViewProvider: AnyVoucherShareableViewProvider

    /// :nodoc:
    private lazy var apiClient: APIClientProtocol = {
        let scheduler = SimpleScheduler(maximumCount: 3)
        return APIClient(apiContext: adyenContext.apiContext)
            .retryAPIClient(with: scheduler)
            .retryOnErrorAPIClient()
    }()
    
    /// :nodoc:
    internal func canAddPasses(action: AnyVoucherAction) -> Bool {
        PKAddPassesViewController.canAddPasses() && action.passCreationToken != nil
    }

    /// :nodoc:
    private let componentName = "voucher"

    /// :nodoc:
    internal let passProvider: AnyAppleWalletPassProvider
    
    /// :nodoc:
    internal var view: VoucherView?

    /// Initializes the `VoucherComponent`.
    ///
    /// - Parameter adyenContext: The Adyen context.
    /// - Parameter configuration: The voucher component configurations.
    public convenience init(adyenContext: AdyenContext,
                            configuration: Configuration = Configuration()) {
        self.init(adyenContext: adyenContext,
                  voucherShareableViewProvider: nil,
                  configuration: configuration,
                  passProvider: AppleWalletPassProvider(adyenContext: adyenContext))
    }

    /// Initializes the `AwaitComponent`.
    /// - Parameter adyenContext: The Adyen context.
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter style: The Component UI style.
    internal init(adyenContext: AdyenContext,
                  voucherShareableViewProvider: AnyVoucherShareableViewProvider?,
                  configuration: Configuration = Configuration(),
                  passProvider: AnyAppleWalletPassProvider?) {
        self.adyenContext = adyenContext
        self.configuration = configuration
        self.voucherShareableViewProvider = voucherShareableViewProvider ??
            VoucherShareableViewProvider(style: configuration.style, environment: adyenContext.apiContext.environment)
        self.passProvider = passProvider ?? AppleWalletPassProvider(adyenContext: adyenContext)
    }

    /// :nodoc:
    public func didCancel() {}

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: VoucherAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: adyenContext.apiContext)
        fetchAndCacheAppleWalletPassIfNeeded(with: action.anyAction)

        voucherShareableViewProvider.localizationParameters = configuration.localizationParameters

        let view = VoucherView(model: viewModel(with: action))
        view.delegate = self
        self.view = view
        let viewController = ADYViewController(view: view)
        
        setUpPresenterViewController(parentViewController: viewController)

        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(
                component: self,
                viewController: viewController,
                navBarType: navBarType()
            )
            presentationDelegate.present(component: presentableComponent)
        } else {
            AdyenAssertion.assertionFailure(
                message: "PresentationDelegate is nil. Provide a presentation delegate to VoucherComponent."
            )
        }
    }
    
    internal let presenterViewController = UIViewController()
        
    private func navBarType() -> NavigationBarType {
        let model = ActionNavigationBar.Model(leadingButtonTitle: Bundle.Adyen.localizedEditCopy,
                                              trailingButtonTitle: Bundle.Adyen.localizedDoneCopy)
        let style = ActionNavigationBar.Style(leadingButton: configuration.style.editButton,
                                              trailingButton: configuration.style.doneButton,
                                              backgroundColor: configuration.style.backgroundColor)
        
        let navBar = ActionNavigationBar(model: model, style: style)
        
        navBar.leadingButtonHandler = {
            navBar.onCancelHandler?()
        }
        
        navBar.trailingButtonHandler = { [weak self] in
            self.map { $0.delegate?.didComplete(from: $0) }
        }
        return .custom(navBar)
    }
    
    private func viewModel(with action: VoucherAction) -> VoucherView.Model {
        let anyAction = action.anyAction
        let viewStyle = VoucherView.Model.Style(
            editButton: configuration.style.editButton,
            doneButton: configuration.style.doneButton,
            mainButton: configuration.style.mainButton,
            secondaryButton: configuration.style.secondaryButton,
            codeConfirmationColor: configuration.style.codeConfirmationColor,
            amountLabel: configuration.style.amountLabel,
            currencyLabel: configuration.style.currencyLabel,
            logoCornerRounding: .fixed(5),
            backgroundColor: configuration.style.backgroundColor
        )
        
        let comps = anyAction.totalAmount.formattedComponents
        
        return VoucherView.Model(
            action: action,
            identifier: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "voucherView"),
            amount: comps.formattedValue,
            currency: comps.formattedCurrencySymbol,
            logoUrl: LogoURLProvider.logoURL(
                withName: anyAction.paymentMethodType.rawValue,
                environment: adyenContext.apiContext.environment,
                size: .medium
            ),
            mainButton: getPrimaryButtonTitle(with: action),
            secondaryButtonTitle: localizedString(.moreOptions, configuration.localizationParameters),
            codeConfirmationTitle: localizedString(.pixInstructionsCopiedMessage, configuration.localizationParameters),
            mainButtonType: canAddPasses(action: action.anyAction) ? .addToAppleWallet : .save,
            style: viewStyle
        )
    }
    
    private func getPrimaryButtonTitle(with action: VoucherAction) -> String {
        if action.anyAction is Downloadable {
            return localizedString(.boletoDownloadPdf, configuration.localizationParameters)
        } else {
            return localizedString(.voucherSaveImage, configuration.localizationParameters)
        }
    }

    private func fetchAndCacheAppleWalletPassIfNeeded(with action: AnyVoucherAction) {
        guard let passToken = action.passCreationToken else { return }
        passProvider.provide(with: passToken) { _ in
            /* Do nothing, this is just to cache the response */
        }
    }

}
