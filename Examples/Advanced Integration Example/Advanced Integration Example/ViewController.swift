//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Adyen
import AdyenCSE

class ViewController: UIViewController {
    let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demo/easy-integration/merchantserver/setup")!
    let appId = "YOU_APP_ID" // provide your app id
    let appSecretKey = "YOUR_APP_SECRET_KEY" // provide your app secret key (to use with Adyen Test Merchant Server)
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cardPayment(_ sender: Any) {
        let request = PaymentRequest(delegate: self)
        request.start()
    }
}

extension ViewController: PaymentRequestDelegate {
    
    func paymentRequest(_ request: PaymentRequest, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {
        
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
    
    func paymentRequest(_ request: PaymentRequest, didFinishWith result: PaymentRequestResult) {
        switch result {
        case let .payment(payment):
            statusLabel.text = payment.status.rawValue
        default:
            statusLabel.text = "Error"
        }
    }
    
    func paymentRequest(_ request: PaymentRequest, requiresPaymentMethodFrom preferredMethods: [PaymentMethod]?, available availableMethods: [PaymentMethod], completion: @escaping MethodCompletion) {
        //  Present list of payment methods to the user
        //  For demo: select card type payment method
        
        //  Get cards method
        var cardsMethod: PaymentMethod?
        for method in availableMethods where method.type == "card" {
            cardsMethod = method
            break
        }
        
        guard let method = cardsMethod else {
            request.cancel()
            return
        }
        
        //  Submit shopper's selection
        completion(method)
    }
    
    func paymentRequest(_ request: PaymentRequest, requiresReturnURLFrom url: URL, completion: @escaping URLCompletion) {}
    
    func paymentRequest(_ request: PaymentRequest, requiresPaymentDetails details: PaymentDetails, completion: @escaping PaymentDetailsCompletion) {
        //  Fill in requested details for the selected payment method
        if let method = request.paymentMethod, method.type == "card" {
            
            if let testCard = testCardData(for: request),
                let publicKey = request.publicKey,
                let encryptedToken = ADYEncrypter.encrypt(testCard, publicKeyInHex: publicKey) {
                
                details.fillCard(token: encryptedToken)
                completion(details)
            } else {
                request.cancel()
            }
        }
    }
}

extension ViewController {
    
    func testCardData(for request: PaymentRequest) -> Data? {
        
        guard let generationTime = request.generationTime else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let generationDate = dateFormatter.date(from: generationTime)
        
        let card = ADYCard()
        card.generationtime = generationDate
        card.holderName = "Checkout Shopper"
        card.number = "5555444433331111"
        card.expiryMonth = "08"
        card.expiryYear = "2018"
        card.cvc = "737"
        
        return card.encode()
    }
}
