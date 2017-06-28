//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Protocol used for Quick integration comunication. All delegate methods are invoked on the main thread.
public protocol CheckoutViewControllerDelegate: class {
    
    /// Given the controller that started the payment flow and `token`, waits for data from merchant server to be passed via `completion`.
    func checkoutViewController(_ controller: CheckoutViewController, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion)
    
    /// This method is called when a URL redirection was made. When the browser process is completed, the `completion` for the given URL must be called.
    func checkoutViewController(_ controller: CheckoutViewController, requiresReturnURL completion: @escaping URLCompletion)
    
    /// This method is called when the payment flow is finished.
    func checkoutViewController(_ controller: CheckoutViewController, didFinishWith result: PaymentRequestResult)
}
