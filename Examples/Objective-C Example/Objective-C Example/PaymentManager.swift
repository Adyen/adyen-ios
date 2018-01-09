//
// Copyright (c) 2018 Adyen B.V.
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
    
    @objc
    public func beginPayment(hostViewController: UIViewController) {
        let checkoutViewController = CheckoutViewController(delegate: self)
        hostViewController.present(checkoutViewController, animated: true)
    }
    
    // MARK: URL Handling
    
    fileprivate var urlCompletion: URLCompletion?
    
    @objc(applicationDidOpenURL:)
    public func applicationDidOpen(_ url: URL) {
        urlCompletion?(url)
    }
    
}

extension PaymentManager: CheckoutViewControllerDelegate {
    
    func checkoutViewController(_ controller: CheckoutViewController, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {
        let appSecretKey = Configuration.appSecretKey
        
        guard appSecretKey.characters.isEmpty == false else {
            fatalError("Fill in a secret key in PaymentManager.swift.")
        }
        
        let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/setup")!
        
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
            "channel": "ios",
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
        controller.presentingViewController?.dismiss(animated: true, completion: {
            self.delegate?.paymentManager(self, didFinishWithResult: PaymentManagerResult(result: result))
        })
    }
    
}
