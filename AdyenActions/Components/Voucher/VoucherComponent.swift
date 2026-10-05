//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import PassKit
import UIKit

/// A component that handles voucher action.
internal protocol AnyVoucherActionHandler: ActionComponent, Cancellable {
    func handle(_ action: VoucherAction)
}

/// A component that handles voucher action.
@MainActor
package final class VoucherComponent: AnyVoucherActionHandler, ShareableComponent {

    /// The context object for this component.
    package let context: AdyenContext

    /// Delegates view controller presentation.
    package weak var actionPresentationDelegate: ActionPresentationDelegate?

    package weak var delegate: ActionComponentDelegate?

    /// The voucher component configurations.
    package struct Configuration {

        /// The theme applied to the component's screens.
        package var theme: CheckoutTheme

        /// The localization parameters, leave it nil to use the default parameters.
        package var localizationParameters: LocalizationParameters?

        package init(
            theme: CheckoutTheme = .default,
            localizationParameters: LocalizationParameters? = nil
        ) {
            self.theme = theme
            self.localizationParameters = localizationParameters
        }
    }
    
    /// The voucher component configurations.
    package var configuration: Configuration

    internal var voucherShareableViewProvider: AnyVoucherShareableViewProvider
    
    internal func canAddPasses(action: AnyVoucherAction) -> Bool {
        PKAddPassesViewController.canAddPasses() && action.passCreationToken != nil
    }

    private let componentName = "voucher"

    internal let passProvider: AnyAppleWalletPassProvider
    
    internal var view: VoucherView?

    /// Initializes the `VoucherComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The voucher component configurations.
    package convenience init(
        context: AdyenContext,
        configuration: Configuration = Configuration()
    ) {
        self.init(
            context: context,
            voucherShareableViewProvider: nil,
            configuration: configuration,
            passProvider: AppleWalletPassProvider(context: context)
        )
    }

    /// Initializes the `VoucherComponent`.
    /// - Parameter context: The context object for this component.
    /// - Parameter voucherShareableViewProvider: Provides view for this component.
    /// - Parameter configuration: The voucher component configurations.
    /// - Parameter passProvider: Object to save the voucher pass in the AppleWallet.
    internal init(
        context: AdyenContext,
        voucherShareableViewProvider: AnyVoucherShareableViewProvider?,
        configuration: Configuration = Configuration(),
        passProvider: AnyAppleWalletPassProvider?
    ) {
        self.context = context
        self.configuration = configuration
        self.voucherShareableViewProvider = voucherShareableViewProvider ??
            VoucherShareableViewProvider(theme: configuration.theme, environment: context.apiContext.environment)
        self.passProvider = passProvider ?? AppleWalletPassProvider(context: context)
    }

    package func didCancel() {}

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    package func handle(_ action: VoucherAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: context.apiContext)
        fetchAndCacheAppleWalletPassIfNeeded(with: action.anyAction)

        voucherShareableViewProvider.localizationParameters = configuration.localizationParameters
        voucherShareableViewProvider.theme = configuration.theme

        let view = VoucherView(model: viewModel(with: action))
        view.delegate = self
        self.view = view
        let viewController = ActionViewController(view: view)
        
        setUpPresenterViewController(parentViewController: viewController)

        if let actionPresentationDelegate {
            actionPresentationDelegate.present(actionViewController: viewController, actionData: ActionData(type: .voucher))
        } else {
            AdyenAssertion.assertionFailure(
                message: "ActionPresentationDelegate is nil. Provide a presentation delegate to VoucherComponent."
            )
        }
    }
    
    internal let presenterViewController = UIViewController()
        
    private func viewModel(with action: VoucherAction) -> VoucherView.Model {
        let anyAction = action.anyAction
        let comps = anyAction.totalAmount.formattedComponents
        
        return VoucherView.Model(
            action: action,
            identifier: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "voucherView"),
            amount: comps.formattedValue,
            currency: comps.formattedCurrencySymbol,
            logoUrl: LogoURLProvider.logoURL(
                withName: anyAction.paymentMethodType.rawValue,
                environment: context.apiContext.environment,
                size: .medium
            ),
            mainButton: getPrimaryButtonTitle(with: action),
            secondaryButtonTitle: localizedString(.moreOptions, configuration.localizationParameters),
            codeConfirmationTitle: localizedString(.pixInstructionsCopiedMessage, configuration.localizationParameters),
            mainButtonType: canAddPasses(action: action.anyAction) ? .addToAppleWallet : .save,
            theme: configuration.theme,
            imageLoader: ImageLoaderProvider.imageLoader()
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
