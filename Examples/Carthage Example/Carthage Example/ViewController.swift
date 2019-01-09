//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

class ViewController: UIViewController {
    private lazy var checkoutController = CheckoutController(presentingViewController: self, delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(Configuration.isFilledIn, "Fill in a secret key in the Configuration.swift file.")
    }
    
    @IBAction private func startCheckout(_ sender: Any) {
        checkoutController.start()
    }
    
    private func presentSuccessAlertController() {
        presentAlertController(with: "Payment Successful")
    }
    
    private func presentFailureAlertController() {
        presentAlertController(with: "Payment Failed")
    }
    
    private func presentAlertController(with message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

extension ViewController: CheckoutControllerDelegate {
    internal func requestPaymentSession(withToken token: String, for checkoutController: CheckoutController, responseHandler: @escaping (String) -> Void) {
        let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/paymentSession")!
        
        let paymentDetails: [String: Any] = [
            "amount": [
                "currency": "EUR",
                "value": 100
            ],
            "reference": "test-payment-reference",
            "token": token,
            "returnUrl": "carthage-example-app://",
            "countryCode": "NL"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "X-Demo-Server-API-Key": Configuration.appSecretKey
        ]
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { data, _, error in
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
        }
        dataTask.resume()
    }
    
    internal func didFinish(with result: Result<PaymentResult>, for checkoutController: CheckoutController) {
        var isSuccess = false
        var isCancelled = false
        
        switch result {
        case let .success(payment):
            isSuccess = (payment.status == .received || payment.status == .authorised)
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
