//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// A component that handles Await action's.
@MainActor
package final class AwaitComponent: ActionComponent, Cancellable {

    /// The context object for this component.
    package let context: AdyenContext

    /// Delegates `PresentableComponent`'s presentation.
    package weak var presentationDelegate: PresentationDelegate?

    package weak var delegate: ActionComponentDelegate?

    internal var appLauncher: AnyAppLauncher = AppLauncher()

    /// The await component configurations.
    package struct Configuration {
        
        /// The component UI style.
        package var style: AwaitComponentStyle
        
        /// The localization parameters, leave it nil to use the default parameters.
        package var localizationParameters: LocalizationParameters?
        
        package init(style: AwaitComponentStyle = .init()) {
            self.init(style: style, localizationParameters: nil)
        }

        package init(
            style: AwaitComponentStyle = .init(),
            localizationParameters: LocalizationParameters? = nil
        ) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
    
    /// The await component configurations.
    package var configuration: Configuration

    private let awaitComponentBuilder: AnyPollingHandlerProvider
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The await component configurations.
    package convenience init(
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.init(
            context: context,
            awaitComponentBuilder: PollingHandlerProvider(context: context),
            configuration: configuration
        )
    }
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter configuration: The Component UI style.
    internal init(
        context: AdyenContext,
        awaitComponentBuilder: AnyPollingHandlerProvider,
        configuration: Configuration = .init()
    ) {
        self.context = context
        self.configuration = configuration
        self.awaitComponentBuilder = awaitComponentBuilder
    }
    
    private let componentName = "await"
    
    /// Handles redirect await action.
    ///
    /// - Parameter action: The await action object.
    package func handle(_ action: RedirectableAwaitAction) {
        appLauncher.openCustomSchemeUrl(action.url) { [weak self] success in
            guard let self else { return }
            if success {
                let awaitAction = AwaitAction(
                    paymentData: action.paymentData,
                    paymentMethodType: action.paymentMethodType
                )
                
                self.handle(awaitAction)
                self.delegate?.didOpenExternalApplication(component: self)
            } else {
                self.delegate?.didFail(with: RedirectComponent.Error.appNotFound, from: self)
                self.didCancel()
            }
        }
    }

    package func didCancel() {
        paymentMethodSpecificPollingComponent?.didCancel()
    }

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    package func handle(_ action: AwaitAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: context.apiContext)

        let viewModel = AwaitComponentViewModel.viewModel(
            with: action.paymentMethodType,
            localizationParameters: configuration.localizationParameters
        )
        let viewController = AwaitViewController(viewModel: viewModel, style: configuration.style)

        if let presentationDelegate {
            presentationDelegate.present(viewController: viewController)
        } else {
            let message = "PresentationDelegate is nil. Provide a presentation delegate to AwaitComponent."
            AdyenAssertion.assertionFailure(message: message)
        }

        paymentMethodSpecificPollingComponent = awaitComponentBuilder.handler(for: action.paymentMethodType)
        paymentMethodSpecificPollingComponent?.delegate = delegate

        paymentMethodSpecificPollingComponent?.handle(action)
    }

    private var paymentMethodSpecificPollingComponent: AnyPollingHandler?
    
}
