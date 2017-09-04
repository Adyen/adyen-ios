//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Adyen

class ViewController: UITableViewController, CheckoutViewControllerDelegate, CheckoutViewControllerCardScanDelegate {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(Configuration.isFilledIn, "Fill in a secret key in the Configuration.swift file.")
    }
    
    // MARK: - UITableViewController
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            presentCheckoutViewController()
        }
    }
    
    // MARK: - Private
    
    @IBOutlet fileprivate var shopperReferenceField: UITextField!
    @IBOutlet fileprivate var shopperCountryField: UITextField!
    
    private func presentCheckoutViewController() {
        let checkoutViewController = CheckoutViewController(delegate: self)
        checkoutViewController.cardScanDelegate = self
        present(checkoutViewController, animated: true)
    }
    
    fileprivate func presentSuccessAlertController() {
        let alertController = UIAlertController(title: "Payment successful", message: nil, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func presentFailureAlertController() {
        let alertController = UIAlertController(title: "Payment failed", message: nil, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate var urlCompletion: URLCompletion?
    
    internal func didReceive(_ url: URL) {
        urlCompletion?(url)
        urlCompletion = nil
    }
    
    // MARK: - CheckoutViewControllerDelegate
    
    func checkoutViewController(_ controller: CheckoutViewController, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {
        let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/setup")!
        
        let paymentDetails: [String: Any] = [
            "amount": [
                "currency": "EUR",
                "value": 17408
            ],
            "channel": "ios",
            "reference": "iOS & M+M Black dress & accessories",
            "token": token,
            "returnUrl": "ui-host://",
            "countryCode": shopperCountryField.text!,
            "shopperReference": shopperReferenceField.text!,
            "shopperLocale": "nl_NL"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "x-demo-server-api-key": Configuration.appSecretKey
        ]
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                completion(data)
            }
        }.resume()
    }
    
    func checkoutViewController(_ controller: CheckoutViewController, requiresReturnURL completion: @escaping URLCompletion) {
        urlCompletion = completion
    }
    
    func checkoutViewController(_ controller: CheckoutViewController, didFinishWith result: PaymentRequestResult) {
        var isSuccess = false
        var isCancelled = false
        
        switch result {
        case let .payment(payment):
            isSuccess = (payment.status == .received || payment.status == .authorised)
        case let .error(error):
            switch error {
            case .cancelled:
                isCancelled = true
            default:
                break
            }
        }
        
        dismiss(animated: true) {
            if isSuccess {
                self.presentSuccessAlertController()
            } else if !isCancelled {
                self.presentFailureAlertController()
            }
        }
    }
    
    // MARK: - CheckoutViewControllerCardScanDelegate
    
    func shouldShowCardScanButton(for checkoutViewController: CheckoutViewController) -> Bool {
        return true
    }
    
    func scanCard(for checkoutViewController: CheckoutViewController, completion: @escaping CardScanCompletion) {
        let alertController = UIAlertController(title: "Scan Card", message: "This is the entry point for integrating your card scanning SDK.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            let number = "5555444433331111"
            let expiryDate = "12/18"
            let cvc = "123"
            
            completion((number: number, expiryDate: expiryDate, cvc: cvc))
        }))
        checkoutViewController.present(alertController, animated: true)
    }
    
}
