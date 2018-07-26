//
// Copyright (c) 2018 Adyen B.V.
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
    ///   - checkoutController: The checkout controller that requires a payment session.
    ///   - token: The token to submit to the /paymentSession endpoint.
    ///   - responseHandler: The closure to invoke when payment session has been received.
    func requestPaymentSession(withToken token: String, for checkoutController: CheckoutController, responseHandler: @escaping Completion<String>)
    
    /// Invoked when the checkout flow has been completed.
    ///
    /// - Parameters:
    ///   - checkoutController: The checkout controller that has completed the checkout flow.
    ///   - result: The result of the checkout.
    func didFinish(with result: Result<PaymentResult>, for checkoutController: CheckoutController)
    
}
