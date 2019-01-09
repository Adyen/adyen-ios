//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

class ShoppingCartViewController: UIViewController {
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var actionButton: UIButton!
    
    let demoServerURL = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/paymentSession")!
    
    lazy var appearance: Appearance = {
        var appearance = Appearance()
        appearance.tintColor = #colorLiteral(red: 0.4107530117, green: 0.8106812239, blue: 0.7224243283, alpha: 1)
        return appearance
    }()
    
    lazy var checkoutController = CheckoutController(presentingViewController: self, delegate: self, appearance: appearance)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard Configuration.appSecretKey.isEmpty == false else {
            fatalError("Please fill in a secret key in the Configuration.swift file.")
        }
    }
    
    @IBAction private func checkout(_ sender: Any) {
        checkoutController.start()
    }
    
    @objc
    private func presentInitialScreen() {
        UIView.transition(
            with: contentImageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { self.contentImageView.image = #imageLiteral(resourceName: "Checkout window") }
        )
        actionButton.setImage(#imageLiteral(resourceName: "Btn_cta"), for: .normal)
        actionButton.removeTarget(self, action: #selector(presentInitialScreen), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(checkout(_:)), for: .touchUpInside)
    }
    
    @objc
    private func presentSuccessScreen() {
        contentImageView.image = #imageLiteral(resourceName: "Success")
        actionButton.setImage(#imageLiteral(resourceName: "back-to-shop"), for: .normal)
        actionButton.removeTarget(self, action: #selector(checkout(_:)), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(presentInitialScreen), for: .touchUpInside)
    }
    
    @objc
    private func presentFailureScreen() {
        contentImageView.image = #imageLiteral(resourceName: "Failure")
        actionButton.setImage(#imageLiteral(resourceName: "try-again"), for: .normal)
        actionButton.removeTarget(self, action: #selector(checkout(_:)), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(presentInitialScreen), for: .touchUpInside)
    }
    
}

extension ShoppingCartViewController: CheckoutControllerDelegate {
    func requestPaymentSession(withToken token: String, for checkoutController: CheckoutController, responseHandler: @escaping (String) -> Void) {
        let paymentDetails: [String: Any] = [
            "amount": [
                "value": 17408,
                "currency": "EUR"
            ],
            "reference": "iOS & M+M Black dress & accessories",
            "countryCode": "NL",
            "shopperLocale": "nl_NL",
            "shopperReference": "shopper@company.com",
            "returnUrl": "example-shopping-app://",
            "token": token
        ]
        
        var request = URLRequest(url: demoServerURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "X-Demo-Server-API-Key": Configuration.appSecretKey
        ]
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                checkoutController.cancel()
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
        task.resume()
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
            presentSuccessScreen()
        } else if !isCancelled {
            presentFailureScreen()
        }
    }
    
}
