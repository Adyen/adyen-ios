//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

@objc class PaymentManager: NSObject {
    struct Configuration {
        static let appSecretKey = ""
    }
    
    @objc
    public weak var delegate: PaymentManagerDelegate?
    
    private var checkoutController: CheckoutController?
    
    @objc
    public func beginPayment(hostViewController: UIViewController) {
        checkoutController = CheckoutController(presentingViewController: hostViewController, delegate: self)
        checkoutController?.start()
    }
    
    @objc(applicationDidOpenURL:)
    public func applicationDidOpen(_ url: URL) {
        Adyen.applicationDidOpen(url)
    }
    
}

extension PaymentManager: CheckoutControllerDelegate {
    func requestPaymentSession(withToken token: String, for checkoutController: CheckoutController, responseHandler: @escaping (String) -> Void) {
        let appSecretKey = Configuration.appSecretKey
        
        guard appSecretKey.isEmpty == false else {
            fatalError("Fill in a secret key in PaymentManager.swift.")
        }
        
        let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/paymentSession")!
        
        let paymentDetails: [String: Any] = [
            "amount": [
                "value": 17408,
                "currency": "EUR"
            ],
            "reference": "iOS & M+M Black dress & accessories",
            "countryCode": "NL",
            "shopperLocale": "nl_NL",
            "shopperReference": "shopper@company.com",
            "returnUrl": "objective-c-example://",
            "token": token
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "x-demo-server-api-key": Configuration.appSecretKey
        ]
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            do {
                guard let data = data, let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { fatalError() }
                guard let paymentSession = json["paymentSession"] as? String else { fatalError() }
                
                responseHandler(paymentSession)
            } catch {
                fatalError("Failed to parse payment session response: \(error)")
            }
        }
        task.resume()
        
    }
    
    func didFinish(with result: Result<PaymentResult>, for checkoutController: CheckoutController) {
        self.delegate?.paymentManager(self, didFinishWithResult: PaymentManagerResult(result: result))
    }
    
}
