//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Defines the functions that should be implemented in order to use the PaymentController.
public protocol PaymentControllerDelegate: AnyObject {
    /// Invoked when the payment flow has started and a payment session is required from the backend.
    /// Use this opportunity to make a request to the /paymentSession API from your backend, including the token.
    /// The value of `paymentSession` inside the response should be passed in the responseHandler.
    ///
    /// - Parameters:
    ///   - paymentController: The payment controller that requires a payment session.
    ///   - token: The token to submit to the /paymentSession endpoint.
    ///   - responseHandler: The closure to invoke when payment session has been received.
    func requestPaymentSession(withToken token: String, for paymentController: PaymentController, responseHandler: @escaping Completion<String>)
    
    /// Invoked when the payment methods available to complete the payment are retrieved.
    /// Use this opportunity to present a list of payment methods to the user and asking the user to fill the required payment details.
    ///
    /// When the payment method contains payment details in its `details` property, make sure to set them before handing back the payment method through the `selectionHandler`.
    ///
    /// - Parameters:
    ///   - paymentMethods: The payment methods from which a payment method can be selected.
    ///   - paymentController: The payment controller that requires a payment method.
    ///   - selectionHandler: The closure to invoke when a payment method has been selected.
    func selectPaymentMethod(from paymentMethods: SectionedPaymentMethods, for paymentController: PaymentController, selectionHandler: @escaping Completion<PaymentMethod>)
    
    /// Invoked when a redirect to a URL is required in order to complete the payment.
    /// It's recommended to use either `SFSafariViewController` or `UIApplication`'s `openURL:` to perform the redirect.
    ///
    /// Make sure to invoke `applicationDidOpen(_:)` in your `UIApplicationDelegate`'s `application(_:open:options:)` in order for Adyen to be able to handle the result.
    ///
    /// - Parameters:
    ///   - url: The URL to redirect the user to.
    ///   - paymentController: The payment controller that requires a redirect.
    func redirect(to url: URL, for paymentController: PaymentController)
    
    /// Invoked when the payment is finished.
    ///
    /// A successful result contains a `payload`. Submit this `payload` through your backend to the `/payments/result` endpoint to verify the integrity of the payment.
    ///
    /// - Parameters:
    ///   - result: The result of the payment.
    ///   - paymentController: The payment controller that finished the payment.
    func didFinish(with result: Result<PaymentResult>, for paymentController: PaymentController)
    
    /// Invoked when additional payment details are needed.
    ///
    /// - Parameters:
    ///   - additionalDetails: Structure containing the details that need to be filled and additional redirect data.
    ///   - paymentMethod: The payment method that is requesting additional details.
    ///   - detailsHandler: The closure to invoke when details are filled.
    func provideAdditionalDetails(_ additionalDetails: AdditionalPaymentDetails, for paymentMethod: PaymentMethod, detailsHandler: @escaping Completion<[PaymentDetail]>)
}
