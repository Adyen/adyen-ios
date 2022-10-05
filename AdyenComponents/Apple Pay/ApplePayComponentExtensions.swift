//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import PassKit

@_spi(AdyenInternal)
extension ApplePayComponent: PKPaymentAuthorizationViewControllerDelegate {
    
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        paymentAuthorizationViewController = nil
        if case let State.finalized(completion) = state {
            completion?()
        } else {
            delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
    }
    
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        guard payment.token.paymentData.isEmpty == false else {
            completion(.failure)
            delegate?.didFail(with: Error.invalidToken, from: self)
            return
        }

        state = .paid(completion)
        let token = payment.token.paymentData.base64EncodedString()
        let network = payment.token.paymentMethod.network?.rawValue ?? ""
        let details = ApplePayDetails(paymentMethod: applePayPaymentMethod,
                                      token: token,
                                      network: network,
                                      billingContact: payment.billingContact,
                                      shippingContact: payment.shippingContact,
                                      shippingMethod: payment.shippingMethod)
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: applePayPayment.amount, order: order))
    }

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelectShippingContact contact: PKContact,
        handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void
    ) {
        guard let applePayDelegate = applePayDelegate else {
            return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
        }

        applePayDelegate.didUpdate(contact: contact,
                                   for: applePayPayment) { [weak self] result in
            guard let self = self else { return }
            self.updateApplePayPayment(result)
            completion(result)
        }
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didSelect shippingMethod: PKShippingMethod,
                                                   handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        guard let applePayDelegate = applePayDelegate else {
            return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
        }

        applePayDelegate.didUpdate(shippingMethod: shippingMethod,
                                   for: applePayPayment) { [weak self] result in
            guard let self = self else { return }
            self.updateApplePayPayment(result)
            completion(result)
        }
    }

    @available(iOS 15.0, *)
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didChangeCouponCode couponCode: String,
                                                   handler completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
        guard let applePayDelegate = applePayDelegate else {
            return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
        }

        applePayDelegate.didUpdate(couponCode: couponCode,
                                   for: applePayPayment) { [weak self] result in
            guard let self = self else { return }
            self.updateApplePayPayment(result)
            completion(result)
        }
    }

    private func updateApplePayPayment<T: PKPaymentRequestUpdate>(_ result: T) {
        if result.status == .success, result.paymentSummaryItems.count > 0 {
            do {
                applePayPayment = try applePayPayment.replacing(summaryItems: result.paymentSummaryItems)
            } catch {
                delegate?.didFail(with: error, from: self)
            }
        }
    }

}
