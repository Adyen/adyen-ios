//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

internal class ApplePayDetailsPresenter: NSObject, PaymentDetailsPresenter {
    
    private let hostViewController: UINavigationController
    
    private let pluginConfiguration: PluginConfiguration
    
    internal weak var delegate: PaymentDetailsPresenterDelegate?
    
    required init(hostViewController: UINavigationController, pluginConfiguration: PluginConfiguration) {
        self.hostViewController = hostViewController
        self.pluginConfiguration = pluginConfiguration
    }
    
    internal func start() {
        hostViewController.present(paymentAuthorizationViewController, animated: true)
    }
    
    fileprivate func submit(token: String?, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        paymentAuthorizationViewControllerCompletion = completion
        
        let paymentDetails = PaymentDetails(details: pluginConfiguration.paymentMethod.inputDetails ?? [])
        if let token = token {
            paymentDetails.fillApplePay(token: token)
        }
        
        delegate?.paymentDetailsPresenter(self, didSubmit: paymentDetails)
    }
    
    internal func finish(with paymentStatus: PaymentStatus, completion: @escaping () -> Void) {
        let authorizationStatus = paymentStatus.paymentAuthorizationStatus
        paymentAuthorizationViewControllerCompletion?(authorizationStatus)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: completion)
    }
    
    // MARK: - Payment Authorization Controller
    
    private lazy var paymentAuthorizationViewController: PKPaymentAuthorizationViewController = {
        let pluginConfiguration = self.pluginConfiguration
        let paymentRequest = PKPaymentRequest(paymentMethod: pluginConfiguration.paymentMethod,
                                              paymentSetup: pluginConfiguration.paymentSetup)
        
        guard let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            fatalError("Failed to instantiate PKPaymentAuthorizationViewController.")
        }
        paymentAuthorizationViewController.delegate = self
        
        return paymentAuthorizationViewController
    }()
    
    private var paymentAuthorizationViewControllerCompletion: ((PKPaymentAuthorizationStatus) -> Void)? // swiftlint:disable:this identifier_name
    
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate

extension ApplePayDetailsPresenter: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        let token = String(data: payment.token.paymentData, encoding: .utf8)
        submit(token: token, completion: completion)
    }
    
}

// MARK: - PKPaymentRequest

fileprivate extension PKPaymentRequest {
    
    fileprivate convenience init(paymentMethod: PaymentMethod, paymentSetup: PaymentSetup) {
        self.init()
        
        countryCode = paymentSetup.countryCode
        currencyCode = paymentSetup.currencyCode
        supportedNetworks = [.masterCard, .visa, .amex]
        merchantCapabilities = .capability3DS
        merchantIdentifier = paymentMethod.configuration?["merchantIdentifier"] as? String ?? ""
        
        let amount = NSDecimalNumber(value: paymentSetup.amount).dividing(by: NSDecimalNumber(value: 100.0))
        let summaryItem = PKPaymentSummaryItem(label: paymentSetup.merchantReference, amount: amount)
        paymentSummaryItems = [summaryItem]
    }
    
}

// MARK: - PaymentStatus

fileprivate extension PaymentStatus {
    
    fileprivate var paymentAuthorizationStatus: PKPaymentAuthorizationStatus {
        switch self {
        case .authorised, .received:
            return .success
        default:
            return .failure
        }
    }
    
}
