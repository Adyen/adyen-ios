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

/// The `CheckoutViewControllerCardScanDelegate` protocol defines methods that the `cardScanDelegate` of `CheckoutViewController` should implement to enable card scanning functionality for card payment methods.
///
/// The Adyen SDK does not provide card scanning functionality, but allows you to connect your own or third-party card scanning flows by conforming to this protocol. By providing a `cardScanDelegate` object that conforms to `CheckoutViewControllerCardScanDelegate`, you will be able to specify whether or not a card scan button should be shown, receive a callback when this button is tapped, and provide scan results back to the SDK through a completion block.
public protocol CheckoutViewControllerCardScanDelegate: class {
    
    // MARK: - Managing Scan Button Visibility
    
    /// Invoked when the card payment method is selected.
    ///
    /// - Parameter checkoutViewController: The checkout view controller that started the payment flow.
    /// - Returns: A boolean value indicating whether or not a card scan button should be present, so that a card scanning SDK can be integrated.
    func shouldShowCardScanButton(for checkoutViewController: CheckoutViewController) -> Bool
    
    // MARK: - Handling Scan Action
    
    /// Invoked when the card scan button is tapped.
    /// This is the entry point for integrating the card scanning SDK.
    ///
    /// - Parameters:
    ///   - checkoutViewController: The checkout view controller that started the payment flow.
    ///   - completion: The handler to invoke once card number and expiry date have been scanned.
    ///                 The `CardScanCompletion` handler expects card number, expiry date (MMYY) and CVC as optional
    ///                 numerical strings with no spaces. Illegal characters are stripped out of all strings.
    func scanCard(for checkoutViewController: CheckoutViewController, completion: @escaping CardScanCompletion)
    
}
