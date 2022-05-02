//
//  ApplePayDelegateMock.swift
//  AdyenUIKitTests
//
//  Created by Vladimir Abramichev on 02/05/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Adyen
import AdyenComponents
import PassKit

final class ApplePayDelegateMock: ApplePayComponentDelegate {

    var didUpdate: ((PaymentComponentData, PaymentComponent) -> Void)?

    func didUpdate(contact: PKContact, for payment: ApplePayPayment, with completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        <#code#>
    }

    func didUpdate(shippingMethod: PKShippingMethod, for payment: ApplePayPayment, with completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        <#code#>
    }

    @available(iOS 15.0, *)
    func didUpdate(couponCode: String, for payment: ApplePayPayment, with completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
        <#code#>
    }
}
