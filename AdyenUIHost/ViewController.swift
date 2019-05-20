//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import UIKit

class ViewController: UITableViewController {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(Configuration.isFilledIn, "Fill in a secret key in the Configuration.swift file.")
    }
    
    // MARK: - UITableViewController
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            checkoutController.start()
        }
    }
    
    // MARK: - Private
    
    @IBOutlet fileprivate var amountField: UITextField!
    @IBOutlet fileprivate var currencyField: UITextField!
    @IBOutlet fileprivate var countryField: UITextField!
    @IBOutlet fileprivate var referenceField: UITextField!
    @IBOutlet fileprivate var shopperLocaleField: UITextField!
    @IBOutlet fileprivate var shopperReferenceField: UITextField!
    
    private lazy var checkoutController: CheckoutController = {
        let checkoutController = CheckoutController(presentingViewController: self, delegate: self)
        checkoutController.cardScanDelegate = self
        return checkoutController
    }()
    
    private func presentSuccessAlertController() {
        let alertController = UIAlertController(title: "Payment successful", message: nil, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentFailureAlertController() {
        let alertController = UIAlertController(title: "Payment failed", message: nil, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

extension ViewController: CheckoutControllerDelegate {
    func requestPaymentSession(withToken token: String, for checkoutController: CheckoutController, responseHandler: @escaping (String) -> Void) {
        let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/paymentSession")!
        
        let value = Int(amountField.text!)!
        
        var paymentDetails: [String: Any] = [
            "amount": [
                "currency": currencyField.text!,
                "value": value
            ],
            "channel": "ios",
            "reference": referenceField.text!,
            "token": token,
            "configuration": [
                "cardHolderName": "required"
            ],
            "returnUrl": "ui-host://",
            "countryCode": countryField.text!,
            "shopperReference": shopperReferenceField.text!,
            "shopperLocale": shopperLocaleField.text!,
            "company": [
                "name": "Test Company",
                "registrationNumber": "9501412121",
                "taxId": "94-2404110",
                "registryLocation": "California",
                "type": "Computer",
                "homepage": "http://www.google.com"
            ]
        ]
        
        // Mock line item values
        let lineItem1AmountIncludingTax = value / 2
        let lineItem1TaxAmount = lineItem1AmountIncludingTax / 4
        let lineItem1AmountExcludingTax = lineItem1AmountIncludingTax - lineItem1TaxAmount
        let lineItem2AmountIncludingTax = value - lineItem1AmountIncludingTax
        let lineItem2TaxAmount = lineItem2AmountIncludingTax / 4
        let lineItem2AmountExcludingTax = lineItem2AmountIncludingTax - lineItem2TaxAmount
        
        if lineItem1AmountExcludingTax > 0 && lineItem2AmountExcludingTax > 0 {
            paymentDetails["lineItems"] = [
                [
                    "id": "1",
                    "description": "Test Item 1",
                    "amountExcludingTax": lineItem1AmountExcludingTax,
                    "amountIncludingTax": lineItem1AmountIncludingTax,
                    "taxAmount": (lineItem1TaxAmount / lineItem1AmountExcludingTax) * 100,
                    "taxPercentage": 1800,
                    "quantity": 1,
                    "taxCategory": "High"
                ],
                [
                    "id": "2",
                    "description": "Test Item 2",
                    "amountExcludingTax": lineItem2AmountExcludingTax,
                    "amountIncludingTax": lineItem2AmountIncludingTax,
                    "taxAmount": lineItem2TaxAmount,
                    "taxPercentage": (lineItem2TaxAmount / lineItem2AmountExcludingTax) * 100,
                    "quantity": 5,
                    "taxCategory": "Low"
                ]
            ]
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "x-demo-server-api-key": Configuration.apiKey
        ]
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, _, error in
            if let error = error {
                fatalError("Failed to retrieve payment session: \(error)")
            } else if let data = data {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { fatalError() }
                    guard let paymentSession = json["paymentSession"] as? String else { fatalError() }
                    
                    responseHandler(paymentSession)
                } catch {
                    fatalError("Failed to parse payment session response: \(error)")
                }
            }
        }.resume()
    }
    
    func willFinish(with result: Result<PaymentResult>, for checkoutController: CheckoutController, completionHandler: @escaping (() -> Void)) {
        let deadline: DispatchTime = .now() // + 4      // uncomment to simulate a delay for verification
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completionHandler()
        }
    }
    
    func didFinish(with result: Result<PaymentResult>, for checkoutController: CheckoutController) {
        var isSuccess = false
        var isCancelled = false
        
        switch result {
        case let .success(paymentResult):
            isSuccess = (paymentResult.status == .received || paymentResult.status == .authorised)
        case let .failure(error):
            switch error {
            case PaymentController.Error.cancelled:
                isCancelled = true
            default:
                break
            }
        }
        
        if isSuccess {
            self.presentSuccessAlertController()
        } else if !isCancelled {
            self.presentFailureAlertController()
        }
    }
}

extension ViewController: CardScanDelegate {
    func isCardScanEnabled(for paymentMethod: PaymentMethod) -> Bool {
        return true
    }
    
    func scanCard(for paymentMethod: PaymentMethod, completion: @escaping CardScanCompletion) {
        let alertController = UIAlertController(title: "Scan Card", message: "This is the entry point for integrating your card scanning SDK.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            let holderName = "John S."
            let number = "4111111111111111"
            let expiryDate = "08/20"
            let securityCode = "737"
            
            completion((holderName: holderName, number: number, expiryDate: expiryDate, securityCode: securityCode))
        }))
        
        if let presented = self.presentedViewController {
            presented.present(alertController, animated: true)
        } else {
            present(alertController, animated: true)
        }
    }
}
