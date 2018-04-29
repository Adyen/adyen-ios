//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

internal class ApplePayDetailsPresenter: NSObject, PaymentDetailsPresenter {

    /// Ignored in this presenter.
    var navigationMode: NavigationMode = .present
    
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
        paymentSummaryItems = PKPaymentRequest.paymentSummaryItems(paymentSetup)
    }
    
    private static func paymentSummaryItems(_ paymentSetup: PaymentSetup) -> [PKPaymentSummaryItem] {
        let lineItems = PKPaymentRequest.lineItems(paymentSetup)
        let summaryItem = PKPaymentRequest.paymentSummaryLineItem(paymentSetup)
        let paymentSummaryItems = lineItems + [summaryItem]
        return paymentSummaryItems
    }
    
    private static func lineItems(_ paymentSetup: PaymentSetup) -> [PKPaymentSummaryItem] {
        guard let lineItems = paymentSetup.lineItems, lineItems.count > 0 else {
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
        
        if totalIncludingTax == paymentSetup.amount {
            // Show each item on its own line, without a new line for tax.
            for item in lineItems {
                let amount = item.amountIncludingTax ?? 0
                let formattedAmount = AmountFormatter.decimalAmount(amount, currencyCode: paymentSetup.currencyCode)
                let description = item.description ?? ""
                let lineItem = PKPaymentSummaryItem(label: description, amount: formattedAmount)
                items.append(lineItem)
            }
        } else if totalWithTaxExplicitlyAdded == paymentSetup.amount {
            // Show each item on its own line, with a new line for tax.
            for item in lineItems {
                let amount = item.amountExcludingTax ?? 0
                let formattedAmount = AmountFormatter.decimalAmount(amount, currencyCode: paymentSetup.currencyCode)
                let description = item.description ?? ""
                let lineItem = PKPaymentSummaryItem(label: description, amount: formattedAmount)
                items.append(lineItem)
            }
            
            let taxLabel = ADYLocalizedString("taxLabel")
            let taxAmount = lineItems.compactMap({ $0.taxAmount }).reduce(0, +)
            let formattedTaxAmount = AmountFormatter.decimalAmount(taxAmount, currencyCode: paymentSetup.currencyCode)
            let taxLineItem = PKPaymentSummaryItem(label: taxLabel, amount: formattedTaxAmount)
            
            items.append(taxLineItem)
        }
        
        return items
    }
    
    private static func paymentSummaryLineItem(_ paymentSetup: PaymentSetup) -> PKPaymentSummaryItem {
        let companyName = paymentSetup.companyDetails?.name ?? paymentSetup.merchantReference
        let amount = AmountFormatter.decimalAmount(paymentSetup.amount, currencyCode: paymentSetup.currencyCode)
        let summaryItem = PKPaymentSummaryItem(label: companyName, amount: amount)
        return summaryItem
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
