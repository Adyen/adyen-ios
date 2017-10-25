//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Adyen

class ShoppingCartViewController: UIViewController, CheckoutViewControllerDelegate, CheckoutViewControllerCardScanDelegate, CardIOPaymentViewControllerDelegate {
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    
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
            case .cancelled:
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
        // Customize appearance of SDK.
        var appearance = AppearanceConfiguration.default
        appearance.tintColor = #colorLiteral(red: 0.4107530117, green: 0.8106812239, blue: 0.7224243283, alpha: 1)
        appearance.checkoutButtonType = CustomButton.self
        
        let checkoutViewController = CheckoutViewController(delegate: self, appearanceConfiguration: appearance)
        checkoutViewController.cardScanDelegate = self
        present(checkoutViewController, animated: true)
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
    
    private func presentSuccessScreen() {
        contentImageView.image = #imageLiteral(resourceName: "Success")
        actionButton.setImage(#imageLiteral(resourceName: "back-to-shop"), for: .normal)
        actionButton.removeTarget(self, action: #selector(checkout(_:)), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(presentInitialScreen), for: .touchUpInside)
    }
    
    private func presentFailureScreen() {
        contentImageView.image = #imageLiteral(resourceName: "Failure")
        actionButton.setImage(#imageLiteral(resourceName: "try-again"), for: .normal)
        actionButton.removeTarget(self, action: #selector(checkout(_:)), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(presentInitialScreen), for: .touchUpInside)
    }
    
}
