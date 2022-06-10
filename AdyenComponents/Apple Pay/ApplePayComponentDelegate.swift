//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import PassKit

/// Delegates methods that respond to shopper interactions with payment authorization view controller.
public protocol ApplePayComponentDelegate: AnyObject {

    /// Tells the delegate that the shopper selected a shipping address, and asks for an updated payment request.
    func didUpdate(contact: PKContact,
                   for payment: ApplePayPayment,
                   completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void)

    /// Tells the delegate that the shopper selected a shipping method, and asks for an updated payment request.
    func didUpdate(shippingMethod: PKShippingMethod,
                   for payment: ApplePayPayment,
                   completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void)

    /// Tells the delegate that the shopper entered or updated a coupon code.
    @available(iOS 15.0, *)
    func didUpdate(couponCode: String,
                   for payment: ApplePayPayment,
                   completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void)

}
