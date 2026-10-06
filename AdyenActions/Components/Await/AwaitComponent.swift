//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenUI
import Foundation
import SwiftUI

/// A component that handles Await action's.
@MainActor
package final class AwaitComponent: ActionComponent, Cancellable {

    /// The await component configurations.
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

    // MARK: - Properties

    /// The context object for this component.
    package let context: AdyenContext

    /// Delegates view controller presentation.
    package weak var actionPresentationDelegate: ActionPresentationDelegate?

    package weak var delegate: ActionComponentDelegate?

    internal var appLauncher: AnyAppLauncher = AppLauncher()

    private var pollingHandler: AnyPollingHandler?
    
    /// The await component configurations.
    package var configuration: Configuration

    private let pollingHandlerProvider: AnyPollingHandlerProvider
    
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
            pollingHandlerProvider: PollingHandlerProvider(context: context),
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
        pollingHandlerProvider: AnyPollingHandlerProvider,
        configuration: Configuration = .init()
    ) {
        self.context = context
        self.configuration = configuration
        self.pollingHandlerProvider = pollingHandlerProvider
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
        pollingHandler?.didCancel()
    }

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    package func handle(_ action: AwaitAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: context.apiContext)

        let viewModel = AwaitComponentViewModel(
            paymentMethodType: action.paymentMethodType,
            environment: context.apiContext.environment,
            localizationParameters: configuration.localizationParameters
        )
        let viewController = UIHostingController(rootView: AwaitView(viewModel: viewModel, theme: configuration.theme))
        viewController.sizingOptions = .preferredContentSize

        if let actionPresentationDelegate {
            actionPresentationDelegate.present(actionViewController: viewController, actionData: ActionData(type: .await))
        } else {
            let message = "ActionPresentationDelegate is nil. Provide a presentation delegate to AwaitComponent."
            AdyenAssertion.assertionFailure(message: message)
        }

        pollingHandler = pollingHandlerProvider.handler(for: action.paymentMethodType)
        pollingHandler?.delegate = self
        pollingHandler?.handle(action)
    }
}

// MARK: - ActionComponentDelegate

extension AwaitComponent: ActionComponentDelegate {

    package func didProvide(
        _ data: ActionComponentData,
        from component: any ActionComponent
    ) {
        delegate?.didProvide(data, from: component)
    }
    
    package func didComplete(
        from component: any ActionComponent
    ) {
        delegate?.didComplete(from: component)
    }
    
    package func didFail(
        with error: any Error,
        from component: any ActionComponent
    ) {
        delegate?.didFail(with: error, from: component)
    }
}
