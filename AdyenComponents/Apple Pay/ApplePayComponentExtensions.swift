//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

/// :nodoc:
extension ApplePayComponent: PKPaymentAuthorizationViewControllerDelegate {
    
    /// :nodoc:
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        paymentAuthorizationViewController = nil
        if resultConfirmed {
            finalizeCompletion?()
        } else {
            delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
    }
    
    /// :nodoc:
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        guard payment.token.paymentData.isEmpty == false else {
            completion(.failure)
            delegate?.didFail(with: Error.invalidToken, from: self)
            return
        }

        paymentAuthorizationCompletion = completion
        let token = payment.token.paymentData.base64EncodedString()
        let network = payment.token.paymentMethod.network?.rawValue ?? ""
        let details = ApplePayDetails(paymentMethod: applePayPaymentMethod,
                                      token: token,
                                      network: network,
                                      billingContact: payment.billingContact,
                                      shippingContact: payment.shippingContact,
                                      shippingMethod: payment.shippingMethod)
        
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: self.amountToPay, order: order))
    }

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelectShippingContact contact: PKContact,
        handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void
    ) {
        guard let applePayDelegate = applePayDelegate else {
            return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
        }

        let applePayPayment = self.applePayPayment
        applePayDelegate.didUpdate(contact: contact,
                                   for: applePayPayment,
                                   with: { [weak self] result in
                                       guard let self = self else {
                                           return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
                                       }
            
                                       if result.status == .success,
                                          result.paymentSummaryItems.isEmpty == false {
                                           do {
                                               try self.applePayPayment.update(with: result.paymentSummaryItems)
                                           } catch {
                                               self.delegate?.didFail(with: error, from: self)
                                           }
                                       }
                                       completion(result)
                                   })
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didSelect shippingMethod: PKShippingMethod,
                                                   handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        guard let applePayDelegate = applePayDelegate else {
            return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
        }

        let applePayPayment = self.applePayPayment
        applePayDelegate.didUpdate(shippingMethod: shippingMethod,
                                   for: applePayPayment,
                                   with: { [weak self] result in
                                       guard let self = self else {
                                           return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
                                       }

                                       if result.status == .success,
                                          result.paymentSummaryItems.isEmpty == false {
                                           do {
                                               try self.applePayPayment.update(with: result.paymentSummaryItems)
                                           } catch {
                                               self.delegate?.didFail(with: error, from: self)
                                           }
                                       }
                                       completion(result)
                                   })
    }

    @available(iOS 15.0, *)
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didChangeCouponCode couponCode: String,
                                                   handler completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
        guard let applePayDelegate = applePayDelegate else {
            return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
        }

        let applePayPayment = self.applePayPayment
        applePayDelegate.didUpdate(couponCode: couponCode,
                                   for: applePayPayment,
                                   with: { [weak self] result in
                                       guard let self = self else {
                                           return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
                                       }
            
                                       if result.status == .success,
                                          result.paymentSummaryItems.isEmpty == false {
                                           do {
                                               try self.applePayPayment.update(with: result.paymentSummaryItems)
                                           } catch {
                                               self.delegate?.didFail(with: error, from: self)
                                           }
                                       }
                                       completion(result)
                                   })
    }
}

public protocol ApplePayComponentDelegate: AnyObject {

    func didUpdate(contact: PKContact,
                   for payment: ApplePayPayment,
                   with completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void)

    func didUpdate(shippingMethod: PKShippingMethod,
                   for payment: ApplePayPayment,
                   with completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void)

    @available(iOS 15.0, *)
    func didUpdate(couponCode: String,
                   for payment: ApplePayPayment,
                   with completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void)
    
}
