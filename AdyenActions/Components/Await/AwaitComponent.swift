//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// A component that handles Await action's.
public final class AwaitComponent: ActionComponent, Cancellable {
    
    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext
    
    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    public weak var delegate: ActionComponentDelegate?
    
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
    
    private let awaitComponentBuilder: AnyPollingHandlerProvider
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The await component configurations.
    public convenience init(context: AdyenContext,
                            configuration: Configuration = .init()) {
        self.init(context: context,
                  awaitComponentBuilder: PollingHandlerProvider(context: context),
                  configuration: configuration)
    }
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter configuration: The Component UI style.
    internal init(context: AdyenContext,
                  awaitComponentBuilder: AnyPollingHandlerProvider,
                  configuration: Configuration = .init()) {
        self.context = context
        self.configuration = configuration
        self.awaitComponentBuilder = awaitComponentBuilder
    }
    
    private let componentName = "await"
    
    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: AwaitAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: context.apiContext)
        
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
    
    public func didCancel() {
        paymentMethodSpecificPollingComponent?.didCancel()
    }
    
    private var paymentMethodSpecificPollingComponent: AnyPollingHandler?
    
}
