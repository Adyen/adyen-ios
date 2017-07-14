//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// The `CheckoutViewControllerDelegate` protocol defines the methods that a delegate of `CheckoutViewController` should implement to provide payment data and be informed of the payment flow progress.
public protocol CheckoutViewControllerDelegate: class {
    
    /// Invoked when the payment flow has started and payment data is requested from the merchant server.
    ///
    /// - Parameters:
    ///   - controller: The checkout view controller that has started the payment flow.
    ///   - token: The token assigned to the payment flow.
    ///   - completion: The completion handler to invoke when the payment data is retrieved from the merchant server.
    func checkoutViewController(_ controller: CheckoutViewController, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion)
    
    /// Invoked when the redirection to a URL has been made. The given completion handler should be invoked when the user returns to the application through a URL.
    ///
    /// - Parameters:
    ///   - controller: The checkout view controller which requested the return from a URL redirection.
    ///   - completion: The completion handler to invoke when the user returns to the application through a URL.
    func checkoutViewController(_ controller: CheckoutViewController, requiresReturnURL completion: @escaping URLCompletion)
    
    /// Invoked when the payment flow has finished.
    ///
    /// - Parameters:
    ///   - controller: The checkout view controller that finished the payment flow.
    ///   - result: The payment result.
    func checkoutViewController(_ controller: CheckoutViewController, didFinishWith result: PaymentRequestResult)
    
}
