//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import PassKit

@_spi(AdyenInternal)
extension ApplePayComponent: PKPaymentAuthorizationViewControllerDelegate {
    
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        if configuration.dismissesAutomatically {
            controller.dismiss(animated: true) { [weak self] in
                self?.handleViewControllerDidFinish()
            }
        } else {
            handleViewControllerDidFinish()
        }
    }
    
    private func handleViewControllerDidFinish() {
        switch state {
        case let .finalized(completion):
            completion?()
        case .initial:
            // User cancelled without authorizing payment - allow component reuse
            paymentAuthorizationViewController = nil
            delegate?.didFail(with: ComponentError.cancelled, from: self)
        case .submitted:
            // Payment authorized but finalizeIfNeeded not called
            // we call didFail here to not cause a breaking behavior change
            delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
    }
    
    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        guard payment.token.paymentData.isEmpty == false else {
            completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
            delegate?.didFail(with: Error.invalidToken, from: self)
            return
        }

        // Call the authorization delegate's didAuthorize method for validation
        // If no delegate is set, proceed directly with payment submission
        if let authorizationDelegate {
            authorizationDelegate.didAuthorize(payment: payment) { [weak self] result in
                guard let self else { return }
                if result.status == .success {
                    self.proceedWithSubmission(for: payment, completion: completion)
                } else {
                    // Validation failed - pass the result back to Apple Pay
                    completion(result)
                }
            }
        } else {
            proceedWithSubmission(for: payment, completion: completion)
        }
    }
    
    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelectShippingContact contact: PKContact,
        handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void
    ) {
        guard let applePayDelegate else {
            return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
        }

        applePayDelegate.didUpdate(
            contact: contact,
            for: applePayPayment
        ) { [weak self] result in
            guard let self else { return }
            self.updateApplePayPayment(result)
            completion(result)
        }
    }

    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelect shippingMethod: PKShippingMethod,
        handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void
    ) {
        guard let applePayDelegate else {
            return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
        }

        applePayDelegate.didUpdate(
            shippingMethod: shippingMethod,
            for: applePayPayment
        ) { [weak self] result in
            guard let self else { return }
            self.updateApplePayPayment(result)
            completion(result)
        }
    }

    @available(iOS 15.0, *)
    public func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didChangeCouponCode couponCode: String,
        handler completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void
    ) {
        guard let applePayDelegate else {
            return completion(.init(paymentSummaryItems: applePayPayment.summaryItems))
        }

        applePayDelegate.didUpdate(
            couponCode: couponCode,
            for: applePayPayment
        ) { [weak self] result in
            guard let self else { return }
            self.updateApplePayPayment(result)
            completion(result)
        }
    }

    private func updateApplePayPayment(_ result: some PKPaymentRequestUpdate) {
        if result.status == .success, result.paymentSummaryItems.count > 0 {
            do {
                applePayPayment = try applePayPayment.replacing(summaryItems: result.paymentSummaryItems)
            } catch {
                delegate?.didFail(with: error, from: self)
            }
        }
    }
    
    private func proceedWithSubmission(
        for payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        state = .submitted(completion)
        
        let token = payment.token.paymentData.base64EncodedString()
        let network = payment.token.paymentMethod.network?.rawValue ?? ""
        let details = ApplePayDetails(
            paymentMethod: applePayPaymentMethod,
            token: token,
            network: network,
            billingContact: payment.billingContact,
            shippingContact: payment.shippingContact,
            shippingMethod: payment.shippingMethod
        )
        
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: applePayPayment.amount, order: order))
    }
}
