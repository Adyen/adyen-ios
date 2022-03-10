//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// A component that handles Await action's.
public final class AwaitComponent: ActionComponent, Cancellable {
    
    /// :nodoc:
    public let apiContext: APIContext

    /// The Adyen context.
    public let adyenContext: AdyenContext
    
    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    public let requiresModalPresentation: Bool = true
    
    /// The await component configurations.
    public struct Configuration {
        
        /// The component UI style.
        public var style: AwaitComponentStyle
        
        /// The localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?
        
        /// Initializes an instance of `Configuration`
        ///
        /// - Parameters:
        ///   - style: The Component UI style.
        ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
        public init(style: AwaitComponentStyle = .init(),
                    localizationParameters: LocalizationParameters? = nil) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
    
    /// The await component configurations.
    public var configuration: Configuration
    
    /// :nodoc:
    private let awaitComponentBuilder: AnyPollingHandlerProvider
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter adyeContext: The Adyen context.
    /// - Parameter configuration: The await component configurations.
    public convenience init(apiContext: APIContext,
                            adyenContext: AdyenContext,
                            configuration: Configuration = .init()) {
        self.init(apiContext: apiContext,
                  adyenContext: adyenContext,
                  awaitComponentBuilder: PollingHandlerProvider(apiContext: apiContext, adyenContext: adyenContext),
                  configuration: configuration)
    }
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter adyenContext: The Adyen context.
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter configuration: The Component UI style.
    internal init(apiContext: APIContext,
                  adyenContext: AdyenContext,
                  awaitComponentBuilder: AnyPollingHandlerProvider,
                  configuration: Configuration = .init()) {
        self.apiContext = apiContext
        self.adyenContext = adyenContext
        self.configuration = configuration
        self.awaitComponentBuilder = awaitComponentBuilder
    }
    
    /// :nodoc:
    private let componentName = "await"
    
    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: AwaitAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        
        let viewModel = AwaitComponentViewModel.viewModel(with: action.paymentMethodType,
                                                          localizationParameters: configuration.localizationParameters)
        let viewController = AwaitViewController(viewModel: viewModel, style: configuration.style)
        
        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self, viewController: viewController)
            presentationDelegate.present(component: presentableComponent)
        } else {
            let message = "PresentationDelegate is nil. Provide a presentation delegate to AwaitComponent."
            AdyenAssertion.assertionFailure(message: message)
        }
        
        paymentMethodSpecificPollingComponent = awaitComponentBuilder.handler(for: action.paymentMethodType)
        paymentMethodSpecificPollingComponent?.delegate = delegate
        
        paymentMethodSpecificPollingComponent?.handle(action)
    }
    
    /// :nodoc:
    public func didCancel() {
        paymentMethodSpecificPollingComponent?.didCancel()
    }
    
    /// :nodoc:
    private var paymentMethodSpecificPollingComponent: AnyPollingHandler?
    
}
