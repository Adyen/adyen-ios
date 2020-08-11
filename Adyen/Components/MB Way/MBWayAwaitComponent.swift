//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// An MBWay specific await component.
internal final class MBWayAwaitComponent: AnyAwaitComponent {
    
    /// :nodoc:
    internal weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    internal weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    internal let componentName = "mbWayAwait"
    
    /// :nodoc:
    private let apiClient: AnyRetryAPIClient
    
    /// :nodoc:
    /// Initializes the MB Way Await component.
    ///
    /// - Parameter apiClient: The API client.
    internal init(apiClient: AnyRetryAPIClient) {
        self.apiClient = apiClient
    }
    
    /// :nodoc:
    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    internal func handle(_ action: AwaitAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        sendStatusRequest(action)
    }
    
    /// :nodoc:
    private func sendStatusRequest(_ action: AwaitAction) {
        let request = PaymentStatusRequest(paymentData: action.paymentData)
        
        apiClient.perform(request, shouldRetry: { [weak self] result in
            self?.shouldRetry(result, paymentData: action.paymentData) ?? false
        }, completionHandler: { _ in })
    }
    
    /// :nodoc:
    private func shouldRetry(_ result: Result<PaymentStatusResponse, Error>, paymentData: String) -> Bool {
        switch result {
        case let .success(response):
            return shouldRetry(response, paymentData: paymentData)
        case let .failure(error):
            delegate?.didFail(with: error, from: self)
            return false
        }
    }
    
    /// :nodoc:
    private func shouldRetry(_ response: PaymentStatusResponse, paymentData: String) -> Bool {
        switch response.resultCode {
        case .pending, .received:
            return true
        default:
            deliverData(response, paymentData: paymentData)
            return false
        }
    }
    
    /// :nodoc:
    private func deliverData(_ response: PaymentStatusResponse, paymentData: String) {
        let additionalDetails = MBWayActionDetails(payload: response.payload)
        let actionData = ActionComponentData(details: additionalDetails, paymentData: paymentData)
        delegate?.didProvide(actionData, from: self)
    }
}
