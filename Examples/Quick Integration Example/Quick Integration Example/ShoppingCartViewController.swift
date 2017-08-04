//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Adyen

class ShoppingCartViewController: UIViewController, CheckoutViewControllerDelegate, CheckoutViewControllerCardScanDelegate, CardIOPaymentViewControllerDelegate {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard Configuration.appSecretKey.characters.isEmpty == false else {
            fatalError("Please fill in a secret key in the Configuration.swift file.")
        }
    }
    
    // MARK: - CheckoutViewControllerDelegate
    
    func checkoutViewController(_ controller: CheckoutViewController, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {
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
        appUrlCompletion = completion
    }
    
    func checkoutViewController(_ controller: CheckoutViewController, didFinishWith result: PaymentRequestResult) {
        dismiss(animated: true)
        
        var success: Bool = false
        
        switch result {
            
        case let .payment(payment):
            success = (payment.status == .received || payment.status == .authorised)
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
    
    // MARK: - CheckoutViewControllerCardScanDelegate
    
    func shouldShowCardScanButton(for checkoutViewController: CheckoutViewController) -> Bool {
        return true
    }
    
    func scanCard(for checkoutViewController: CheckoutViewController, completion: @escaping CardScanCompletion) {
        if let scanViewController = CardIOPaymentViewController(paymentDelegate: self),
            let presented = presentedViewController {
            scanViewController.suppressScanConfirmation = true
            cardScanCompletion = completion
            presented.present(scanViewController, animated: true)
        } else {
            completion((number: nil, expiryDate: nil, cvc: nil))
        }
    }
    
    // MARK: - CardIOPaymentViewControllerDelegate
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        if let presented = presentedViewController {
            presented.dismiss(animated: true)
        }
        
        cardScanCompletion?((number: nil, expiryDate: nil, cvc: nil))
        cardScanCompletion = nil
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let presented = presentedViewController {
            presented.dismiss(animated: true)
        }
        
        let number = cardInfo.cardNumber
        let month = String(format: "%02d", cardInfo.expiryMonth)
        let year = String(format: "%02d", cardInfo.expiryYear % 100)
        let expiryDate = "\(month)\(year)"
        let cvc = cardInfo.cvv
        cardScanCompletion?((number: number, expiryDate: expiryDate, cvc: cvc))
        cardScanCompletion = nil
    }
    
    // MARK: - Public
    
    func applicationDidReceive(_ url: URL) {
        appUrlCompletion?(url)
    }
    
    // MARK: - Private
    
    private let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/setup")!
    
    private var appUrlCompletion: URLCompletion?
    private var cardScanCompletion: CardScanCompletion?
    
    @IBAction private func checkout(_ sender: Any) {
        let checkoutViewController = CheckoutViewController(delegate: self)
        checkoutViewController.cardScanDelegate = self
        present(checkoutViewController, animated: true)
    }
    
    private func presentScreen(withIdentifier identifier: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
        
        present(viewController, animated: true, completion: nil)
    }
    
    private func presentSuccessScreen() {
        presentScreen(withIdentifier: "SuccessScreen")
    }
    
    private func presentFailureScreen() {
        presentScreen(withIdentifier: "FailureScreen")
    }
    
}
