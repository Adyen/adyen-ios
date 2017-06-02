//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

class ApplePayDetailsPresenter: NSObject, PaymentMethodDetailsPresenter {
    fileprivate var detailsCompletion: ((PaymentDetails) -> Void)?
    fileprivate var requiredPaymentDetails: PaymentDetails?
    fileprivate var applePayCompletion: ((PKPaymentAuthorizationStatus) -> Void)?
    
    private var applePayViewController: PKPaymentAuthorizationViewController?
    private var hostViewController: UIViewController?
    
    func applePayRequest(for paymentRequest: PaymentRequest) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.countryCode = paymentRequest.countryCode!
        request.currencyCode = paymentRequest.currency!
        request.supportedNetworks = [.masterCard, .visa, .amex]
        request.merchantCapabilities = .capability3DS
        
        let merchantIdentifier = paymentRequest.paymentMethod?.configuration?[applePayMerchantIdentifierKey] as? String
        request.merchantIdentifier = merchantIdentifier ?? ""
        
        let totalAmount = NSDecimalNumber(decimal: Decimal(Double(paymentRequest.amount!) / 100.0))
        let totalItem = PKPaymentSummaryItem(label: paymentRequest.reference!, amount: totalAmount)
        request.paymentSummaryItems = [totalItem]
        
        return request
    }
    
    func setup(with hostViewController: UIViewController, paymentRequest: PaymentRequest, paymentDetails: PaymentDetails, completion: @escaping (PaymentDetails) -> Void) {
        self.hostViewController = hostViewController
        requiredPaymentDetails = paymentDetails
        detailsCompletion = completion
        
        applePayViewController = PKPaymentAuthorizationViewController(paymentRequest: applePayRequest(for: paymentRequest))
        applePayViewController?.delegate = self
    }
    
    func present() {
        if let applePayViewController = applePayViewController {
            hostViewController?.present(applePayViewController, animated: true, completion: nil)
        }
    }
    
    func dismiss(animated: Bool, completion: @escaping () -> Void) {
        hostViewController?.dismiss(animated: true, completion: completion)
    }
    
    func finishWith(state: PaymentStatus) {
        let result: PKPaymentAuthorizationStatus = (state == .authorised || state == .received) ? .success : .failure
        applePayCompletion?(result)
    }
}

extension ApplePayDetailsPresenter: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        if let token = String(data: payment.token.paymentData, encoding: .utf8) {
            requiredPaymentDetails?.fillApplePay(token: token)
        }
        
        if let details = requiredPaymentDetails {
            detailsCompletion?(details)
        }
        
        applePayCompletion = completion
    }
}
