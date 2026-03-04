//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenComponents
import PassKit

protocol ApplePayDelegateMock: ApplePayComponentDelegate {
    var contact: PKContact? { get }
    var shippingMethod: PKShippingMethod? { get }
    var couponCode: String? { get }

    var onShippingContactChange: ((PKContact, [PKPaymentSummaryItem]) -> PKPaymentRequestShippingContactUpdate)? { get set }
    var onShippingMethodChange: ((PKShippingMethod, [PKPaymentSummaryItem]) -> PKPaymentRequestShippingMethodUpdate)? { get set }
}

final class ApplePayDelegateMockClassic: ApplePayDelegateMock {

    var contact: PKContact?
    var shippingMethod: PKShippingMethod?
    var couponCode: String?

    var onShippingContactChange: ((PKContact, [PKPaymentSummaryItem]) -> PKPaymentRequestShippingContactUpdate)?
    var onShippingMethodChange: ((PKShippingMethod, [PKPaymentSummaryItem]) -> PKPaymentRequestShippingMethodUpdate)?

    func didUpdate(contact: PKContact, for summaryItems: [PKPaymentSummaryItem], completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        self.contact = contact
        let result = onShippingContactChange!(contact, summaryItems)
        completion(result)
    }

    func didUpdate(shippingMethod: PKShippingMethod, for summaryItems: [PKPaymentSummaryItem], completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        self.shippingMethod = shippingMethod
        let result = onShippingMethodChange!(shippingMethod, summaryItems)
        completion(result)
    }

    @available(iOS 15.0, *)
    func didUpdate(couponCode: String, for summaryItems: [PKPaymentSummaryItem], completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
        fatalError("Use ApplePayDelegateMockiOS15")
    }
}

@available(iOS 15.0, *)
final class ApplePayDelegateMockiOS15: ApplePayDelegateMock {

    var contact: PKContact?
    var shippingMethod: PKShippingMethod?
    var couponCode: String?

    var onShippingContactChange: ((PKContact, [PKPaymentSummaryItem]) -> PKPaymentRequestShippingContactUpdate)?
    var onShippingMethodChange: ((PKShippingMethod, [PKPaymentSummaryItem]) -> PKPaymentRequestShippingMethodUpdate)?

    var onCouponChange: ((String, [PKPaymentSummaryItem]) -> PKPaymentRequestCouponCodeUpdate)?

    func didUpdate(contact: PKContact, for summaryItems: [PKPaymentSummaryItem], completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        self.contact = contact
        let result = onShippingContactChange!(contact, summaryItems)
        completion(result)
    }

    func didUpdate(shippingMethod: PKShippingMethod, for summaryItems: [PKPaymentSummaryItem], completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        self.shippingMethod = shippingMethod
        let result = onShippingMethodChange!(shippingMethod, summaryItems)
        completion(result)
    }

    @available(iOS 15.0, *)
    func didUpdate(couponCode: String, for summaryItems: [PKPaymentSummaryItem], completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
        self.couponCode = couponCode
        let result = onCouponChange!(couponCode, summaryItems)
        completion(result)
    }
}

// MARK: - ApplePayAuthorizationDelegate Mock

final class ApplePayAuthorizationDelegateMock: ApplePayAuthorizationDelegate {
    
    var authorizedPayment: PKPayment?
    var onAuthorize: ((PKPayment) -> PKPaymentAuthorizationResult)?
    
    func didAuthorize(
        payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        self.authorizedPayment = payment
        let result = onAuthorize!(payment)
        completion(result)
    }
}
