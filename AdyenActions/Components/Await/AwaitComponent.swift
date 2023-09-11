//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// A component that handles Await action's.
public final class AwaitComponent: ActionComponent, Cancellable {
    
    /// :nodoc:
    public let apiContext: APIContext
    
    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    public let requiresModalPresentation: Bool = true
    
    /// The Component UI style.
    public let style: AwaitComponentStyle
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    private let awaitComponentBuilder: AnyPollingHandlerProvider
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter style: The Component UI style.
    public convenience init(apiContext: APIContext, style: AwaitComponentStyle?) {
        self.init(apiContext: apiContext,
                  awaitComponentBuilder: PollingHandlerProvider(apiContext: apiContext),
                  style: style)
    }
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter style: The Component UI style.
    internal init(apiContext: APIContext,
                  awaitComponentBuilder: AnyPollingHandlerProvider,
                  style: AwaitComponentStyle?) {
        self.apiContext = apiContext
        self.style = style ?? AwaitComponentStyle()
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
                                                          localizationParameters: localizationParameters)
        let viewController = AwaitViewController(viewModel: viewModel, style: style)
        
        if let presentationDelegate {
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
