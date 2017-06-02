//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Adyen

class ShoppingCartViewController: UIViewController {
    let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demo/easy-integration/merchantserver/setup")!
    let appId = YOU_APP_ID // provide your app id
    let appSecretKey = YOUR_APP_SECRET_KEY // provide your app secret key (to use with Adyen Test Merchant Server)
    
    var appUrlCompletion: URLCompletion?
    var checkoutViewController: CheckoutViewController?
    
    @IBAction func checkout(_ sender: Any) {
        checkoutViewController = CheckoutViewController(delegate: self)
        
        if let vc = checkoutViewController {
            present(vc, animated: true, completion: nil)
        }
    }
    
    func presentSuccessScreen() {
        presentScreen(withIdentifier: "SuccessScreen")
    }
    
    func presentFailureScreen() {
        presentScreen(withIdentifier: "FailureScreen")
    }
}

extension ShoppingCartViewController: CheckoutViewControllerDelegate {
    
    func checkoutViewController(_ controller: CheckoutViewController, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {
        let paymentDetails: [String: Any] = [
            "quantity": 17408,
            "currency": "EUR",
            "basketId": "iOS & M+M Black dress & accessories",
            "customerCountry": "NL",
            "customerId": "shopper@company.com",
            
            "platform": "ios",
            "appUrlScheme": "example-shopping-app://",
            
            "sdkToken": token
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "X-MerchantServer-App-Id": appId,
            "X-MerchantServer-App-SecretKey": appSecretKey
        ]
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                completion(data)
            }
        }.resume()
    }
    
    func checkoutViewController(_ controller: CheckoutViewController, requiresReturnURL completion: @escaping URLCompletion) {
        appUrlCompletion = completion
    }
    
    func checkoutViewController(_ controller: CheckoutViewController, didFinishWith result: PaymentRequestResult) {
        dismiss(animated: true)
        
        var success: Bool = false
        
        switch result {
            
        case let .payment(payment):
            if payment.status == .authorised {
                success = true
            }
            
        case let .error(error):
            switch error {
            case .canceled:
                return
            default:
                break
            }
        }
        
        if success {
            presentSuccessScreen()
        } else {
            presentFailureScreen()
        }
    }
}

extension ShoppingCartViewController {
    
    func applicationDidReceive(_ url: URL) {
        
        appUrlCompletion?(url)
    }
    
    func presentScreen(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        
        present(viewController, animated: true, completion: nil)
    }
}
