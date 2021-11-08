//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

/// :nodoc:
/// A specific await component thats keeps polling the `/status` endpoint to check the payment status.
internal final class PollingComponent: AnyPollingHandler {
    
    private let maxErrorNumber = 1

    private let apiClient: AnyRetryAPIClient

    private var errorCount = 0

    /// :nodoc:
    internal let apiContext: APIContext
    
    /// :nodoc:
    internal weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    internal weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    internal let componentName = "mbWayAwait"
    
    /// :nodoc:
    /// Initializes the Polling Await component.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter apiClient: The API client.
    internal init(apiContext: APIContext,
                  apiClient: AnyRetryAPIClient) {
        self.apiContext = apiContext
        self.apiClient = apiClient
    }
    
    /// :nodoc:
    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    internal func handle(_ action: PaymentDataAware) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        startPolling(action)
    }
    
    /// :nodoc:
    private var isCancelled: Bool = false
    
    /// :nodoc:
    internal func didCancel() {
        isCancelled = true
    }
    
    /// :nodoc:
    /// Starts polling the status end point to check the payment status.
    ///
    /// - Parameter action: The action object.
    private func startPolling(_ action: PaymentDataAware) {
        isCancelled = false
        errorCount = 0
        let request = PaymentStatusRequest(paymentData: action.paymentData)
        
        apiClient.perform(request, shouldRetry: { [weak self] result in
            self?.shouldRetry(result, paymentData: action.paymentData) ?? false
        }, completionHandler: { [weak self] result in
            self?.handle(finalResult: result, paymentData: action.paymentData)
        })
    }
    
    /// :nodoc:
    /// Decides whether the status request should be repeated.
    ///
    /// - Parameter result: The request result.
    /// - Parameter paymentData: The payment data.
    /// - Returns: A boolean value indicating whether the request should be retried.
    private func shouldRetry(_ result: Result<PaymentStatusResponse, Error>, paymentData: String) -> Bool {
        guard !isCancelled else { return false }
        switch result {
        case let .success(response):
            errorCount = 0
            return shouldRetry(response, paymentData: paymentData)
        case .failure:
            errorCount += 1
            return errorCount <= maxErrorNumber
        }
    }
    
    /// :nodoc:
    /// Decides whether the status request should be repeated.
    ///
    /// - Parameter response: The request response.
    /// - Parameter paymentData: The payment data.
    /// - Returns: A boolean value indicating whether the request should be retried.
    private func shouldRetry(_ response: PaymentStatusResponse, paymentData: String) -> Bool {
        switch response.resultCode {
        case .pending, .received:
            return true
        default:
            return false
        }
    }
    
    /// :nodoc:
    /// Handles the final request result.
    ///
    /// - Parameter result: The request result.
    /// - Parameter paymentData: The payment data.
    private func handle(finalResult result: Result<PaymentStatusResponse, Error>, paymentData: String) {
        guard !isCancelled else {
            delegate?.didFail(with: ComponentError.cancelled, from: self)
            return
        }
        switch result {
        case let .success(response):
            deliverData(response, paymentData: paymentData)
        case let .failure(error):
            delegate?.didFail(with: error, from: self)
        }
    }
    
    /// :nodoc:
    private func deliverData(_ response: PaymentStatusResponse, paymentData: String) {
        let additionalDetails = AwaitActionDetails(payload: response.payload)
        let actionData = ActionComponentData(details: additionalDetails, paymentData: paymentData)
        delegate?.didProvide(actionData, from: self)
    }
}
