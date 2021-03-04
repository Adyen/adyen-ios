//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// A component that handles Await action's.
internal protocol AnyAwaitActionHandler: ActionComponent, Cancellable {
    func handle(_ action: AwaitAction)
}

/// A component that handles Await action's.
public final class AwaitComponent: AnyAwaitActionHandler {
    
    /// Delegates `ViewController`'s presentation.
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
    private var awaitActionHandler: AnyAwaitActionHandlerProvider?
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter style: The Component UI style.
    public init(style: AwaitComponentStyle?) {
        self.style = style ?? AwaitComponentStyle()
    }
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter style: The Component UI style.
    internal convenience init(awaitComponentBuilder: AnyAwaitActionHandlerProvider?,
                              style: AwaitComponentStyle?) {
        self.init(style: style)
        self.awaitActionHandler = awaitComponentBuilder
    }
    
    /// :nodoc:
    private let componentName = "await"
    
    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: AwaitAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        let viewModel = AwaitComponentViewModel.viewModel(with: action.paymentMethodType,
                                                          localizationParameters: localizationParameters)
        let viewController = AwaitViewController(viewModel: viewModel, style: style)
        
        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self, viewController: viewController)
            presentationDelegate.present(component: presentableComponent)
        } else {
            assertionFailure("presentationDelegate is nil, please provide a presentation delegate to present the AwaitComponent UI.")
        }
        
        let awaitComponentBuilder = self.awaitActionHandler ?? AwaitActionHandlerProvider(environment: environment, apiClient: nil)
        
        paymentMethodSpecificAwaitComponent = awaitComponentBuilder.handler(for: action.paymentMethodType)
        paymentMethodSpecificAwaitComponent?.delegate = delegate
        
        paymentMethodSpecificAwaitComponent?.handle(action)
    }
    
    /// :nodoc:
    public func didCancel() {
        paymentMethodSpecificAwaitComponent?.didCancel()
    }
    
    /// :nodoc:
    private var paymentMethodSpecificAwaitComponent: AnyAwaitActionHandler?
    
}
