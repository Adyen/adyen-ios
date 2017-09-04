//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Adyen
import AdyenCSE

class PaymentRequestManager: PaymentRequestDelegate {
    
    // MARK: - Object Lifecycle
    
    static let shared = PaymentRequestManager()
    
    // MARK: - PaymentRequestDelegate
    
    func paymentRequest(_ request: PaymentRequest, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {
        let paymentDetails: [String: Any] = [
            "amount": [
                "value": 17408,
                "currency": "USD"
            ],
            "reference": "#237867422",
            "countryCode": "NL",
            "shopperLocale": "nl_NL",
            "shopperReference": "user349857934",
            "returnUrl": "adyenCustomIntegrationExample://",
            "channel": "ios",
            "token": token
        ]
        
        // For your convenience, we offer a test merchant server. Always use your own implementation when testing before going live.
        let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/setup")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
        request.allHTTPHeaderFields = [
            "x-demo-server-api-key": secretKey,
            "Content-Type": "application/json"
        ]
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            if let data = data {
                completion(data)
            }
        }.resume()
    }
    
    func paymentRequest(_ request: PaymentRequest, requiresPaymentMethodFrom preferredMethods: [PaymentMethod]?, available availableMethods: [PaymentMethod], completion: @escaping MethodCompletion) {
        // Ignore preferred payment methods for this demo.
        
        paymentMethods = availableMethods
        paymentMethodCompletion = completion
        postMainThreadNotification(PaymentRequestManager.didUpdatePaymentMethodsNotification)
    }
    
    func paymentRequest(_ request: PaymentRequest, requiresReturnURLFrom url: URL, completion: @escaping URLCompletion) {
        urlCompletion = completion
        let userInfo = [PaymentRequestManager.externalPaymentCompletionURLKey: url]
        postMainThreadNotification(PaymentRequestManager.didRequestExternalPaymentCompletionNotification, userInfo: userInfo)
    }
    
    func paymentRequest(_ request: PaymentRequest, requiresPaymentDetails details: PaymentDetails, completion: @escaping PaymentDetailsCompletion) {
        if let method = request.paymentMethod, method.type == "card" {
            if let cardDetails = cardDetails,
                let cardData = cardDetails.cardData(forRequest: request),
                let publicKey = request.publicKey,
                let encryptedToken = ADYEncrypter.encrypt(cardData, publicKeyInHex: publicKey) {
                details.fillCard(token: encryptedToken, storeDetails: cardDetails.shouldStoreDetails)
                completion(details)
            } else {
                // This should be an edge case, so just fail gracefully.
                // If this becomes a common case, better handling needs to be implemented.
                request.cancel()
            }
        } else {
            // Do nothing. For now only handle cards.
        }
    }
    
    func paymentRequest(_ request: PaymentRequest, didFinishWith result: PaymentRequestResult) {
        switch result {
        case let .payment(payment):
            switch payment.status {
            case .received, .authorised:
                requestStatus = .success
            case .error, .refused:
                requestStatus = .failure
            case .cancelled:
                requestStatus = .cancelled
            }
        case let .error(error):
            switch error {
            case .cancelled:
                requestStatus = .cancelled
            default:
                requestStatus = .failure
            }
        }
        
        let userInfo = [PaymentRequestManager.finishedRequestStatusKey: requestStatus]
        postMainThreadNotification(PaymentRequestManager.didFinishRequestNotification, userInfo: userInfo)
        clearStoredRequestData()
    }
    
    // MARK: - Public
    
    static let didUpdatePaymentMethodsNotification = Notification.Name("didUpdatePaymentMethods")
    
    static let didRequestExternalPaymentCompletionNotification = Notification.Name("didRequestExternalPaymentCompletion")
    static let externalPaymentCompletionURLKey = "externalPaymentCompletionURL"
    
    static let didFinishRequestNotification = Notification.Name("didFinishRequest")
    static let finishedRequestStatusKey = "finishedRequestStatus"
    
    var paymentMethods: [PaymentMethod]?
    
    // This is hardcoded for demo purposes.
    var paymentAmountString: String = "$174.08"
    
    enum RequestStatus {
        case success
        case failure
        case cancelled
        case inProgress
        case none
    }
    
    /**
     If no request is in progress, starts a new request.
     Returns true if it is able to start a new request.
     Otherwise returns false.
 */
    func startNewRequest() -> Bool {
        guard requestStatus != .inProgress else {
            return false
        }
        
        request = PaymentRequest(delegate: self)
        request?.start()
        requestStatus = .inProgress
        
        return true
    }
    
    func cancelRequest() {
        request?.cancel()
    }
    
    func select(paymentMethod: PaymentMethod) {
        paymentMethodCompletion?(paymentMethod)
    }
    
    func processExternalPayment(withURL url: URL) {
        urlCompletion?(url)
    }
    
    /**
     * Parameters:
     *      - name: cardholder name as String
     *      - number: card number as String
     *      - expiryDate: date as String in format MM/YY
     *      - cvc: cvc as String
     */
    func setCardDetailsForCurrentRequest(name: String, number: String, expiryDate: String, cvc: String, shouldSave: Bool) {
        guard expiryDate.characters.count == 5 else {
            // Do nothing if expiry date is in invalid format.
            return
        }
        
        var index = expiryDate.index(expiryDate.startIndex, offsetBy: 2)
        let monthString = expiryDate.substring(to: index)
        
        index = expiryDate.index(expiryDate.startIndex, offsetBy: 3)
        let yearString = "20\(expiryDate.substring(from: index))"
        
        cardDetails = CardDetails(name: name, number: number, expiryMonth: monthString, expiryYear: yearString, cvc: cvc, shouldStoreDetails: shouldSave)
    }
    
    var blockedOutCardNumber: String? {
        guard let cardDetails = cardDetails else {
            return nil
        }
        
        var cardNumber = cardDetails.number
        
        guard cardNumber.characters.count > 4 else {
            return cardNumber
        }
        
        var replacementString = ""
        let numberOfCharactersToReplace = cardNumber.characters.count - 4
        for _ in 0..<numberOfCharactersToReplace {
            replacementString = "\(replacementString)*"
        }
        
        let index = cardNumber.index(cardNumber.startIndex, offsetBy: numberOfCharactersToReplace)
        replacementString = "\(replacementString)\(cardNumber.substring(from: index))"
        return replacementString
    }
    
    // MARK: - Private
    
    private struct CardDetails {
        let name: String
        let number: String
        let expiryMonth: String
        let expiryYear: String
        let cvc: String
        let shouldStoreDetails: Bool
        
        func cardData(forRequest request: PaymentRequest) -> Data? {
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
            card.holderName = name
            card.number = number
            card.expiryMonth = expiryMonth
            card.expiryYear = expiryYear
            card.cvc = cvc
            return card.encode()
        }
    }
    
    private var request: PaymentRequest?
    private var paymentMethodCompletion: MethodCompletion?
    private var urlCompletion: URLCompletion?
    private var cardDetails: CardDetails?
    private var requestStatus: RequestStatus = .none
    
    private let secretKey = ""
    
    private func postMainThreadNotification(_ notificationName: Notification.Name, userInfo: [AnyHashable: Any]? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
        }
    }
    
    private func clearStoredRequestData() {
        request = nil
        paymentMethodCompletion = nil
        urlCompletion = nil
        cardDetails = nil
        paymentMethods = nil
        requestStatus = .none
        PaymentMethodImageCache.shared.removeAllObjects()
    }
    
}
