//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import PassKit

internal final class ApplePayPlugin: Plugin {

    // MARK: - Plugin
    
    override var isDeviceSupported: Bool {
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: ApplePayPlugin.supportedNetworks)
    }
    
    override func present(using navigationController: UINavigationController, completion: @escaping Completion<[PaymentDetail]>) {
        paymentDetailCompletion = completion
        if let newPaymentAuthorizationViewController = newPaymentAuthorizationViewController() {
            paymentAuthorizationViewController = newPaymentAuthorizationViewController
            navigationController.present(newPaymentAuthorizationViewController, animated: true)
        }
    }
    
    override func finish(with result: Result<PaymentResult>, completion: @escaping () -> Void) {
        let authorizationStatus: PKPaymentAuthorizationStatus
        
        switch result {
        case let .success(paymentResult):
            switch paymentResult.status {
            case .authorised, .received:
                authorizationStatus = .success
            default:
                authorizationStatus = .failure
            }
        default:
            authorizationStatus = .failure
        }
        
        paymentAuthorizationCompletion?(authorizationStatus)
        
        // Calling this on a delay gives the Apple Pay UI a chance to finish any animation.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: completion)
    }
    
    // MARK: - Private
    
    fileprivate static var supportedNetworks: [PKPaymentNetwork] {
        return [.visa, .masterCard, .amex, .discover]
    }
    
    private var paymentAuthorizationViewController: PKPaymentAuthorizationViewController?
    
    private var paymentAuthorizationCompletion: ((PKPaymentAuthorizationStatus) -> Void)?
    private var paymentDetailCompletion: (Completion<[PaymentDetail]>)?
    
    private func newPaymentAuthorizationViewController() -> PKPaymentAuthorizationViewController? {
        let paymentRequest = PKPaymentRequest(paymentMethod: paymentMethod, paymentSession: paymentSession)
        
        guard let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            print("Failed to instantiate PKPaymentAuthorizationViewController.")
            return nil
        }
        paymentAuthorizationViewController.delegate = self
        
        return paymentAuthorizationViewController
    }
    
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate

extension ApplePayPlugin: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        paymentAuthorizationViewController = nil
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        guard var detail = paymentMethod.details.applePayToken else {
            return
        }
        
        paymentAuthorizationCompletion = completion
        
        let token = String(data: payment.token.paymentData, encoding: .utf8)
        detail.value = token
        paymentDetailCompletion?([detail])
    }
}

// MARK: - PKPaymentRequest

fileprivate extension PKPaymentRequest {
    fileprivate convenience init(paymentMethod: PaymentMethod, paymentSession: PaymentSession) {
        self.init()
        
        countryCode = paymentSession.payment.countryCode ?? ""
        currencyCode = paymentSession.payment.amount.currencyCode
        supportedNetworks = ApplePayPlugin.supportedNetworks
        merchantCapabilities = .capability3DS
        merchantIdentifier = paymentMethod.configuration?["merchantIdentifier"] as? String ?? ""
        paymentSummaryItems = PKPaymentRequest.paymentSummaryItems(paymentSession)
    }
    
    private static func paymentSummaryItems(_ paymentSession: PaymentSession) -> [PKPaymentSummaryItem] {
        let lineItems = PKPaymentRequest.lineItems(paymentSession)
        let summaryItem = PKPaymentRequest.paymentSummaryLineItem(paymentSession)
        let paymentSummaryItems = lineItems + [summaryItem]
        return paymentSummaryItems
    }
    
    private static func lineItems(_ paymentSession: PaymentSession) -> [PKPaymentSummaryItem] {
        guard let lineItems = paymentSession.lineItems, lineItems.count > 0 else {
            return []
        }
        
        // Make sure all items have a description, otherwise we won't have anything to display.
        let itemDescriptions = lineItems.compactMap({ $0.description })
        guard itemDescriptions.count == lineItems.count else {
            return []
        }
        
        var items: [PKPaymentSummaryItem] = []
        
        let totalIncludingTax = lineItems.compactMap({ $0.amountIncludingTax }).reduce(0, +)
        let totalWithTaxExplicitlyAdded = lineItems.compactMap({
            ($0.amountExcludingTax ?? 0) + ($0.taxAmount ?? 0)
        }).reduce(0, +)
        
        let paymentAmount = paymentSession.payment.amount
        let paymentValue = paymentAmount.value
        if totalIncludingTax == paymentValue {
            // Show each item on its own line, without a new line for tax.
            for item in lineItems {
                let amount = item.amountIncludingTax ?? 0
                let formattedAmount = AmountFormatter.decimalAmount(amount, currencyCode: paymentAmount.currencyCode)
                let description = item.description ?? ""
                let lineItem = PKPaymentSummaryItem(label: description, amount: formattedAmount)
                items.append(lineItem)
            }
        } else if totalWithTaxExplicitlyAdded == paymentValue {
            // Show each item on its own line, with a new line for tax.
            for item in lineItems {
                let amount = item.amountExcludingTax ?? 0
                let formattedAmount = AmountFormatter.decimalAmount(amount, currencyCode: paymentAmount.currencyCode)
                let description = item.description ?? ""
                let lineItem = PKPaymentSummaryItem(label: description, amount: formattedAmount)
                items.append(lineItem)
            }
            
            let taxLabel = ADYLocalizedString("taxLabel")
            let taxAmount = lineItems.compactMap({ $0.taxAmount }).reduce(0, +)
            let formattedTaxAmount = AmountFormatter.decimalAmount(taxAmount, currencyCode: paymentAmount.currencyCode)
            let taxLineItem = PKPaymentSummaryItem(label: taxLabel, amount: formattedTaxAmount)
            
            items.append(taxLineItem)
        }
        
        return items
    }
    
    private static func paymentSummaryLineItem(_ paymentSession: PaymentSession) -> PKPaymentSummaryItem {
        let companyName = paymentSession.company?.name ?? paymentSession.payment.merchantReference
        let paymentAmount = paymentSession.payment.amount
        let amount = AmountFormatter.decimalAmount(paymentAmount.value, currencyCode: paymentAmount.currencyCode)
        let summaryItem = PKPaymentSummaryItem(label: companyName, amount: amount)
        return summaryItem
    }
    
}
