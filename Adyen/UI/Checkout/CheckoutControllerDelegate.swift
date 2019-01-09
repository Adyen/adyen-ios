//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Defines the methods that should be implemented in order to use the CheckoutController.
public protocol CheckoutControllerDelegate: AnyObject {
    /// Invoked when the checkout flow has started and a payment session is required from the backend.
    /// Use this opportunity to make a request to the /paymentSession API from your backend, including the token.
    /// The paymentSession inside the response should be passed in the responseHandler.
    ///
    /// - Parameters:
    ///   - token: The token to submit to the /paymentSession endpoint.
    ///   - checkoutController: The checkout controller that requires a payment session.
    ///   - responseHandler: The closure to invoke when payment session has been received.
    func requestPaymentSession(withToken token: String, for checkoutController: CheckoutController, responseHandler: @escaping Completion<String>)
    
    /// Invoked when the checkout flow is ready to be dismissed.
    /// Until the completionHandler is called, the UI remains presented. The default implementation calls completionHandler immediately.
    /// Use this opportunity to optionally perform any additional logic before dismissal, i.e. verifying the payload.
    ///
    /// - Parameters:
    ///   - result: The result of the checkout.
    ///   - checkoutController: The checkout controller that is ready to complete the checkout flow.
    ///   - completionHandler: The closure to invoke when ready for the flow to finish.
    func willFinish(with result: Result<PaymentResult>, for checkoutController: CheckoutController, completionHandler: @escaping (() -> Void))
    
    /// Invoked when the checkout flow has been completed.
    ///
    /// - Parameters:
    ///   - result: The result of the checkout.
    ///   - checkoutController: The checkout controller that has completed the checkout flow.
    func didFinish(with result: Result<PaymentResult>, for checkoutController: CheckoutController)
    
}

public extension CheckoutControllerDelegate {
    
    func willFinish(with result: Result<PaymentResult>, for checkoutController: CheckoutController, completionHandler: @escaping (() -> Void)) {
        completionHandler()
    }
    
}
