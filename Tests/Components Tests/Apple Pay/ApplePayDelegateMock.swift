//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenComponents
import PassKit

protocol ApplePayDelegateMock: ApplePayComponentDelegate {
    var contact: PKContact? { get }
    var shippingMethod: PKShippingMethod? { get }
    var couponCode: String? { get }

    var onShippingContactChange: ((PKContact, ApplePayPayment) -> PKPaymentRequestShippingContactUpdate)? { get set }
    var onShippingMethodChange: ((PKShippingMethod, ApplePayPayment) -> PKPaymentRequestShippingMethodUpdate)? { get set }
}

final class ApplePayDelegateMockClassic: ApplePayDelegateMock {

    var contact: PKContact?
    var shippingMethod: PKShippingMethod?
    var couponCode: String?

    var onShippingContactChange: ((PKContact, ApplePayPayment) -> PKPaymentRequestShippingContactUpdate)?
    var onShippingMethodChange: ((PKShippingMethod, ApplePayPayment) -> PKPaymentRequestShippingMethodUpdate)?

    func didUpdate(contact: PKContact, for payment: ApplePayPayment, completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        self.contact = contact
        let result = onShippingContactChange!(contact, payment)
        completion(result)
    }

    func didUpdate(shippingMethod: PKShippingMethod, for payment: ApplePayPayment, completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        self.shippingMethod = shippingMethod
        let result = onShippingMethodChange!(shippingMethod, payment)
        completion(result)
    }

    @available(iOS 15.0, *)
    func didUpdate(couponCode: String, for payment: ApplePayPayment, completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
        fatalError("Use ApplePayDelegateMockiOS15")
    }
}

@available(iOS 15.0, *)
final class ApplePayDelegateMockiOS15: ApplePayDelegateMock {

    var contact: PKContact?
    var shippingMethod: PKShippingMethod?
    var couponCode: String?

    var onShippingContactChange: ((PKContact, ApplePayPayment) -> PKPaymentRequestShippingContactUpdate)?
    var onShippingMethodChange: ((PKShippingMethod, ApplePayPayment) -> PKPaymentRequestShippingMethodUpdate)?

    var onCouponChange: ((String, ApplePayPayment) -> PKPaymentRequestCouponCodeUpdate)?

    func didUpdate(contact: PKContact, for payment: ApplePayPayment, completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        self.contact = contact
        let result = onShippingContactChange!(contact, payment)
        completion(result)
    }

    func didUpdate(shippingMethod: PKShippingMethod, for payment: ApplePayPayment, completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        self.shippingMethod = shippingMethod
        let result = onShippingMethodChange!(shippingMethod, payment)
        completion(result)
    }

    @available(iOS 15.0, *)
    func didUpdate(couponCode: String, for payment: ApplePayPayment, completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
        self.couponCode = couponCode
        let result = onCouponChange!(couponCode, payment)
        completion(result)
    }
}
