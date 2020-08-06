//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that handles Await action's.
public final class AwaitComponent: ActionComponent {
    
    /// :nodoc:
    public weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    private let componentName = "await"
    
    /// :nodoc:
    public let requiresModalPresentation: Bool = true
    
    /// The Component UI style.
    public let style: AwaitComponentStyle
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter style: The Component UI style.
    public init(style: AwaitComponentStyle?) {
        self.style = style ?? AwaitComponentStyle()
    }
    
    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: AwaitAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        registerRedirectBounceBackListener(action)
        
        let viewModel = AwaitComponentViewModel.viewModel(with: action.paymentMethodType)
        let viewController = AwaitViewController(viewModel: viewModel, style: style)
        
        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self, viewController: viewController)
            presentationDelegate.present(component: presentableComponent, disableCloseButton: false)
        } else {
            fatalError("presentationDelegate is nil, please provide a presentation delegate to present the AwaitComponent UI.")
        }
    }
    
    /// :nodoc:
    private func registerRedirectBounceBackListener(_ action: AwaitAction) {
        RedirectListener.registerForURL { [weak self] returnURL in
            guard let self = self else { return }
            
            let additionalDetails = RedirectDetails(returnURL: returnURL)
            let actionData = ActionComponentData(details: additionalDetails, paymentData: action.paymentData)
            self.delegate?.didProvide(actionData, from: self)
        }
    }
    
}
