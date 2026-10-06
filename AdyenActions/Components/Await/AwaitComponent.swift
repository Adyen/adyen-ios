//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
#if canImport(AdyenUI)
    import AdyenUI
#endif
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

    /// The await flow handled by the component.
    internal enum Flow {
        case standard(AwaitAction)
        case redirectable(RedirectableAwaitAction)
    }

    // MARK: - Properties

    /// The context object for this component.
    package let context: AdyenContext

    package weak var delegate: ActionComponentDelegate?

    /// Delegates view controller presentation.
    private weak var actionPresentationDelegate: ActionPresentationDelegate?

    /// The await component configurations.
    private let configuration: Configuration

    private let flow: Flow

    private let appLauncher: AnyAppLauncher

    private let pollingHandler: AnyPollingHandler

    private let componentName = "await"

    /// Initializes the `AwaitComponent` for an await action.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter action: The await action object.
    /// - Parameter actionPresentationDelegate: The delegate presenting the component's view controller.
    /// - Parameter configuration: The await component configurations.
    package convenience init(
        context: AdyenContext,
        action: AwaitAction,
        actionPresentationDelegate: ActionPresentationDelegate,
        configuration: Configuration = .init()
    ) {
        self.init(
            context: context,
            flow: .standard(action),
            actionPresentationDelegate: actionPresentationDelegate,
            configuration: configuration,
            pollingHandlerProvider: PollingHandlerProvider(context: context)
        )
    }

    /// Initializes the `AwaitComponent` for a redirectable await action.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter action: The redirectable await action object.
    /// - Parameter actionPresentationDelegate: The delegate presenting the component's view controller.
    /// - Parameter configuration: The await component configurations.
    package convenience init(
        context: AdyenContext,
        action: RedirectableAwaitAction,
        actionPresentationDelegate: ActionPresentationDelegate,
        configuration: Configuration = .init()
    ) {
        self.init(
            context: context,
            flow: .redirectable(action),
            actionPresentationDelegate: actionPresentationDelegate,
            configuration: configuration,
            pollingHandlerProvider: PollingHandlerProvider(context: context)
        )
    }

    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter flow: The await flow to handle.
    /// - Parameter actionPresentationDelegate: The delegate presenting the component's view controller.
    /// - Parameter configuration: The await component configurations.
    /// - Parameter appLauncher: The app launcher used to open the redirect URL.
    /// - Parameter pollingHandlerProvider: The payment method specific polling handler provider.
    internal init(
        context: AdyenContext,
        flow: Flow,
        actionPresentationDelegate: ActionPresentationDelegate,
        configuration: Configuration = .init(),
        appLauncher: AnyAppLauncher = AppLauncher(),
        pollingHandlerProvider: AnyPollingHandlerProvider
    ) {
        self.context = context
        self.flow = flow
        self.actionPresentationDelegate = actionPresentationDelegate
        self.configuration = configuration
        self.appLauncher = appLauncher
        self.pollingHandler = pollingHandlerProvider.handler(for: flow.paymentMethodType)
        pollingHandler.delegate = self
    }

    /// Handles the await action provided at initialization.
    package func handle() {
        switch flow {
        case let .standard(action):
            handle(action)
        case let .redirectable(action):
            handle(action)
        }
    }

    package func didCancel() {
        pollingHandler.didCancel()
    }

    // MARK: - Private

    private func handle(_ action: RedirectableAwaitAction) {
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

    private func handle(_ action: AwaitAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: context.apiContext)

        guard let actionPresentationDelegate else {
            let message = "ActionPresentationDelegate is nil. Provide a presentation delegate to AwaitComponent."
            AdyenAssertion.assertionFailure(message: message)
            return
        }

        let viewModel = AwaitComponentViewModel(
            paymentMethodType: action.paymentMethodType,
            environment: context.apiContext.environment,
            localizationParameters: configuration.localizationParameters
        )
        let viewController = UIHostingController(rootView: AwaitView(viewModel: viewModel, theme: configuration.theme))
        viewController.sizingOptions = .preferredContentSize

        actionPresentationDelegate.present(actionViewController: viewController, actionData: ActionData(type: .await))
        pollingHandler.handle(action)
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

private extension AwaitComponent.Flow {

    var paymentMethodType: AwaitPaymentMethod {
        switch self {
        case let .standard(action):
            return action.paymentMethodType
        case let .redirectable(action):
            return action.paymentMethodType
        }
    }
}
