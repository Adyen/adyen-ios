//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Adyen

class ViewController: UITableViewController {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isConfigured = !(Configuration.appIdentifier.characters.isEmpty || Configuration.appIdentifier.characters.isEmpty)
        assert(isConfigured, "Fill in an app identifier and secret key in the Configuration.swift file.")
    }
    
    // MARK: - UITableViewController
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            presentCheckoutViewController()
        }
    }
    
    // MARK: - Private
    
    @IBOutlet fileprivate var shopperReferenceField: UITextField!
    
    private func presentCheckoutViewController() {
        let checkoutViewController = CheckoutViewController(delegate: self)
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
    
}

extension ViewController: CheckoutViewControllerDelegate {
    
    func checkoutViewController(_ controller: CheckoutViewController, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {
        let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demo/easy-integration/merchantserver/setup")!
        
        let paymentDetails: [String: Any] = [
            "quantity": 17408,
            "currency": "EUR",
            "basketId": "iOS & M+M Black dress & accessories",
            "customerCountry": "NL",
            "customerId": shopperReferenceField.text!,
            "platform": "ios",
            "appUrlScheme": "ui-host://",
            "sdkToken": token
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "X-MerchantServer-App-Id": Configuration.appIdentifier,
            "X-MerchantServer-App-SecretKey": Configuration.appSecretKey
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
            case .canceled:
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
    
}
