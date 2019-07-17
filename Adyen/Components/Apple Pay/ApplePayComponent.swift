//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

/// A component that wraps ApplePay payments.
public class ApplePayComponent: NSObject, PaymentComponent, PresentableComponent {
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// The apple pay payment method.
    public let paymentMethod: PaymentMethod
    
    /// The line items for this payment.
    public let summaryItems: [PKPaymentSummaryItem]
    
    /// Initializes the component.
    ///
    /// - Parameter paymentMethod: The apple pay payment method.
    /// - Parameter merchantIdentifier: The merchant identifier..
    /// - Parameter summaryItems: The line items for this payment.
    public init?(paymentMethod: PaymentMethod, merchantIdentifier: String, summaryItems: [PKPaymentSummaryItem]) {
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: ApplePayComponent.supportedNetworks) else {
            print("Failed to instantiate ApplePayComponent. PKPaymentAuthorizationViewController.canMakePayments returned false.")
            return nil
        }
        
        self.merchantIdentifier = merchantIdentifier
        self.paymentMethod = paymentMethod
        self.summaryItems = summaryItems
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var viewController: UIViewController {
        return paymentAuthorizationViewController ?? errorAlertController
    }
    
    /// :nodoc:
    public var preferredPresentationMode: PresentableComponentPresentationMode {
        return .present
    }
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        paymentAuthorizationCompletion?(success ? .success : .failure)
        dismissCompletion = completion
    }
    
    // MARK: - Private
    
    private var paymentAuthorizationCompletion: ((PKPaymentAuthorizationStatus) -> Void)?
    
    private var dismissCompletion: (() -> Void)?
    
    private let merchantIdentifier: String
    
    private var errorAlertController = UIAlertController(title: ADYLocalizedString("adyen.error.title"),
                                                         message: ADYLocalizedString("adyen.error.unknown"),
                                                         preferredStyle: .alert)
    
    private var paymentAuthorizationViewController: PKPaymentAuthorizationViewController? {
        guard let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            print("Failed to instantiate PKPaymentAuthorizationViewController.")
            return nil
        }
        paymentAuthorizationViewController.delegate = self
        
        return paymentAuthorizationViewController
    }
    
    private var paymentRequest: PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        
        paymentRequest.countryCode = payment?.countryCode ?? ""
        paymentRequest.merchantIdentifier = merchantIdentifier
        paymentRequest.currencyCode = payment?.amount.currencyCode ?? ""
        paymentRequest.supportedNetworks = ApplePayComponent.supportedNetworks
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.paymentSummaryItems = summaryItems
        
        return paymentRequest
    }
    
    private static var supportedNetworks: [PKPaymentNetwork] {
        var networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .discover]
        
        if #available(iOS 12.0, *) {
            networks.append(.maestro)
        }
        
        return networks
    }
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate

extension ApplePayComponent: PKPaymentAuthorizationViewControllerDelegate {
    
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: dismissCompletion)
    }
    
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        paymentAuthorizationCompletion = completion
        
        let token = String(data: payment.token.paymentData, encoding: .utf8) ?? ""
        let details = ApplePayDetails(type: paymentMethod.type, token: token)
        
        self.delegate?.didSubmit(PaymentComponentData(paymentMethodDetails: details), from: self)
    }
}
