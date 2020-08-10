//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal final class MBWayAwaitComponent: AnyAwaitComponent {
    
    /// :nodoc:
    internal weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    internal weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    internal let componentName = "mbWayAwait"
    
    /// :nodoc:
    private let apiClient: AnyRetryAPIClient
    
    /// Initializes the MB Way Await component.
    ///
    /// - Parameter apiClient: The API client.
    internal init(apiClient: AnyRetryAPIClient) {
        self.apiClient = apiClient
    }
    
    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    internal func handle(_ action: AwaitAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        sendStatusRequest(action)
    }
    
    private func sendStatusRequest(_ action: AwaitAction) {
        let request = PaymentStatusRequest(paymentData: action.paymentData)
        
        apiClient.perform(request, shouldRetry: { [weak self] result in
            self?.shouldRetry(result) ?? false
        }, completionHandler: { _ in })
    }
    
    private func shouldRetry(_ result: Result<PaymentStatusResponse, Error>) -> Bool {
        switch result {
        case let .success(response):
            return shouldRetry(response.resultCode)
        default:
            return true
        }
    }
    
    private func shouldRetry(_ resultCode: PaymentResultCode) -> Bool {
        switch resultCode {
        case .pending, .received:
            return true
        default:
            return false
        }
    }
}
