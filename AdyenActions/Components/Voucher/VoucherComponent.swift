//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import PassKit
import SwiftUI
import UIKit

/// A component that handles voucher action.
internal protocol AnyVoucherActionHandler: ActionComponent, Cancellable {
    func handle(_ action: VoucherAction)
}

/// A component that handles voucher action.
public final class VoucherComponent: AnyVoucherActionHandler, ShareableComponent {

    /// :nodoc:
    public let apiContext: APIContext

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
        return APIClient(apiContext: apiContext)
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
    /// - Parameter apiContext: The API context.
    /// - Parameter configuration: The voucher component configurations.
    public convenience init(apiContext: APIContext, configuration: Configuration = Configuration()) {
        self.init(
            apiContext: apiContext,
            voucherShareableViewProvider: nil,
            configuration: configuration,
            passProvider: AppleWalletPassProvider(apiContext: apiContext)
        )
    }

    /// Initializes the `AwaitComponent`.
    /// - Parameter apiContext: The API context.
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter style: The Component UI style.
    internal init(
        apiContext: APIContext,
        voucherShareableViewProvider: AnyVoucherShareableViewProvider?,
        configuration: Configuration = Configuration(),
        passProvider: AnyAppleWalletPassProvider?
    ) {
        self.apiContext = apiContext
        self.configuration = configuration
        self.voucherShareableViewProvider = voucherShareableViewProvider ??
            VoucherShareableViewProvider(style: configuration.style, environment: apiContext.environment)
        self.passProvider = passProvider ?? AppleWalletPassProvider(apiContext: apiContext)
    }

    /// :nodoc:
    public func didCancel() {}

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: VoucherAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: apiContext)
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
                viewController: viewController
            )
            viewController.navigationItem.rightBarButtonItem = createRightNavigationBarItem()
            presentationDelegate.present(component: presentableComponent)
        } else {
            AdyenAssertion.assertionFailure(
                message: "PresentationDelegate is nil. Provide a presentation delegate to VoucherComponent."
            )
        }
    }
    
    internal let presenterViewController = UIViewController()
        
    private func createRightNavigationBarItem() -> UIBarButtonItem {
        let trailingButton = UIButton(style: configuration.style.doneButton)
        trailingButton.translatesAutoresizingMaskIntoConstraints = false
        trailingButton.setTitle(Bundle.Adyen.localizedDoneCopy, for: .normal)
        trailingButton.addTarget(self, action: #selector(onTrailingButtonTap), for: .touchUpInside)
        trailingButton.contentHorizontalAlignment = .trailing
        return UIBarButtonItem(customView: trailingButton)
    }
    
    @objc private func onTrailingButtonTap() {
        delegate?.didComplete(from: self)
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
                environment: apiContext.environment,
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
