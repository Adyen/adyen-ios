//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that handles Await action's.
internal protocol AnyAwaitComponent: ActionComponent {
    func handle(_ action: AwaitAction)
}

/// A component that handles Await action's.
public final class AwaitComponent: AnyAwaitComponent {
    
    /// :nodoc:
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
    private var apiClient: AnyRetryAPIClient?
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter style: The Component UI style.
    public init(style: AwaitComponentStyle?) {
        self.style = style ?? AwaitComponentStyle()
    }
    
    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter apiClient: The API client.
    /// - Parameter style: The Component UI style.
    internal convenience init(apiClient: AnyRetryAPIClient? = nil,
                              style: AwaitComponentStyle?) {
        self.init(style: style)
        self.apiClient = apiClient
    }
    
    /// :nodoc:
    private let componentName = "await"
    
    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: AwaitAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        let viewModel = AwaitComponentViewModel.viewModel(with: action.paymentMethodType)
        let viewController = AwaitViewController(viewModel: viewModel, style: style)
        
        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self, viewController: viewController)
            presentationDelegate.present(component: presentableComponent, disableCloseButton: false)
        } else {
            fatalError("presentationDelegate is nil, please provide a presentation delegate to present the AwaitComponent UI.")
        }
        
        paymentMethodSpecificAwaitComponent = buildPaymentMethodSpecificAwaitComponent(action.paymentMethodType)
        paymentMethodSpecificAwaitComponent?.delegate = delegate
        
        paymentMethodSpecificAwaitComponent?.handle(action)
    }
    
    /// :nodoc:
    private func buildPaymentMethodSpecificAwaitComponent(_ paymentMethodType: AwaitPaymentMethod) -> AnyAwaitComponent {
        switch paymentMethodType {
        case .mbway:
            let scheduler = BackoffScheduler(queue: .main)
            let baseAPIClient = APIClient(environment: environment)
            let apiClient = self.apiClient ?? RetryAPIClient(apiClient: baseAPIClient, scheduler: scheduler)
            return MBWayAwaitComponent(apiClient: apiClient)
        }
    }
    
    /// :nodoc:
    private var paymentMethodSpecificAwaitComponent: AnyAwaitComponent?
    
}
