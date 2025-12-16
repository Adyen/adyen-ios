//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import PassKit

/// Delegate methods that respond to shopper interactions with payment authorization view controller.
public protocol ApplePayComponentDelegate: AnyObject {

    /// Tells the delegate that the shopper selected a shipping address, and asks for an updated payment request.
    func didUpdate(
        contact: PKContact,
        for payment: ApplePayPayment,
        completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void
    )

    /// Tells the delegate that the shopper selected a shipping method, and asks for an updated payment request.
    func didUpdate(
        shippingMethod: PKShippingMethod,
        for payment: ApplePayPayment,
        completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void
    )

    /// Tells the delegate that the shopper entered or updated a coupon code.
    @available(iOS 15.0, *)
    func didUpdate(
        couponCode: String,
        for payment: ApplePayPayment,
        completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void
    )
}

/// Delegate that handles Apple Pay payment authorization validation.
///
/// Implement this protocol to validate the shopper's payment information (e.g., billing/shipping address)
/// before the payment is submitted to Adyen.
public protocol ApplePayAuthorizationDelegate: AnyObject {
    
    /// Tells the delegate that the shopper authorized the payment and asks for a validation result.
    ///
    /// Use this method to validate the shopper's payment information (e.g., billing/shipping address)
    /// before the payment is submitted. You can perform synchronous or asynchronous validation,
    /// including backend calls if needed.
    ///
    /// - Parameters:
    ///   - payment: The authorized payment containing the token, billing/shipping contacts, and shipping method.
    ///   - completion: The completion handler to call with the validation result.
    ///   Call with `.success` to proceed, or `.failure` with errors to let the shopper retry.
    ///
    /// - Note: Return `.failure` with non-empty `errors` to keep the sheet open for correction.
    ///   Use `PKPaymentRequest.paymentBillingAddressInvalidError(withKey:localizedDescription:)` or similar
    ///   factory methods to create field-specific errors. If `errors` is empty on `.failure`, the system dismisses the sheet.
    func didAuthorize(
        payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationResult) -> Void
    )
}
