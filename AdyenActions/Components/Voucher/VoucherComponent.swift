//
// Copyright (c) 2021 Adyen N.V.
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

    /// :nodoc:
    public let apiContext: APIContext

    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?

    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?

    /// :nodoc:
    public let requiresModalPresentation: Bool = true

    /// The Component UI style.
    public let style: VoucherComponentStyle

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    /// :nodoc:
    internal var voucherShareableViewProvider: AnyVoucherShareableViewProvider
    
    /// :nodoc:
    internal var action: VoucherAction?

    /// :nodoc:
    private lazy var apiClient: APIClientProtocol = {
        let scheduler = SimpleScheduler(maximumCount: 3)
        return APIClient(apiContext: apiContext)
            .retryAPIClient(with: scheduler)
            .retryOnErrorAPIClient()
    }()
    
    /// :nodoc:
    internal var canAddPasses: Bool {
        PKAddPassesViewController.canAddPasses() && action.flatMap(\.anyAction.passCreationToken) != nil
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
    /// - Parameter style: The Component UI style.
    public convenience init(apiContext: APIContext, style: VoucherComponentStyle?) {
        self.init(
            apiContext: apiContext,
            voucherShareableViewProvider: nil,
            style: style ?? VoucherComponentStyle(),
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
        style: VoucherComponentStyle,
        passProvider: AnyAppleWalletPassProvider?
    ) {
        self.apiContext = apiContext
        self.style = style
        self.voucherShareableViewProvider = voucherShareableViewProvider ??
            VoucherShareableViewProvider(style: style, environment: apiContext.environment)
        self.passProvider = passProvider ?? AppleWalletPassProvider(apiContext: apiContext)
    }

    /// :nodoc:
    public func didCancel() {}

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: VoucherAction) {
        self.action = action
        
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        fetchAndCacheAppleWalletPassIfNeeded(with: action.anyAction)

        voucherShareableViewProvider.localizationParameters = localizationParameters

        let view = VoucherView(model: viewModel(with: action))
        view.delegate = self
        self.view = view
        let viewController = ADYViewController(view: view)
        
        setUpPresenterViewController(parentViewController: viewController)

        if let presentationDelegate {
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
        let style = ActionNavigationBar.Style(leadingButton: style.editButton,
                                              trailingButton: style.doneButton,
                                              backgroundColor: style.backgroundColor)
        
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
            editButton: style.editButton,
            doneButton: style.doneButton,
            mainButton: style.mainButton,
            secondaryButton: style.secondaryButton,
            codeConfirmationColor: style.codeConfirmationColor,
            amountLabel: style.amountLabel,
            currencyLabel: style.currencyLabel,
            logoCornerRounding: .fixed(5),
            backgroundColor: style.backgroundColor
        )
        
        let comps = anyAction.totalAmount.formattedComponents
        
        return VoucherView.Model(
            identifier: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "voucherView"),
            amount: comps.formattedValue,
            currency: comps.formattedCurrencySymbol,
            logoUrl: LogoURLProvider.logoURL(
                withName: anyAction.paymentMethodType.rawValue,
                environment: apiContext.environment,
                size: .medium
            ),
            mainButton: getPrimaryButtonTitle(with: action),
            secondaryButtonTitle: localizedString(.moreOptions, localizationParameters),
            codeConfirmationTitle: localizedString(.pixInstructionsCopiedMessage, localizationParameters),
            mainButtonType: canAddPasses ? .addToAppleWallet : .save,
            style: viewStyle
        )
    }
    
    private func getPrimaryButtonTitle(with action: VoucherAction) -> String {
        if action.anyAction is DownloadableVoucher {
            return localizedString(.boletoDownloadPdf, localizationParameters)
        } else {
            return localizedString(.voucherSaveImage, localizationParameters)
        }
    }

    private func fetchAndCacheAppleWalletPassIfNeeded(with action: AnyVoucherAction) {
        guard let passToken = action.passCreationToken else { return }
        passProvider.provide(with: passToken) { _ in
            /* Do nothing, this is just to cache the response */
        }
    }

}
