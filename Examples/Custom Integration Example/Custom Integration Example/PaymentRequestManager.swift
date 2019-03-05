//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

class PaymentRequestManager {
    
    // MARK: - Object Lifecycle
    
    static let shared = PaymentRequestManager()
    
    // MARK: - Public
    
    static let didUpdatePaymentMethodsNotification = Notification.Name("didUpdatePaymentMethods")
    
    static let didRequestExternalPaymentCompletionNotification = Notification.Name("didRequestExternalPaymentCompletion")
    static let externalPaymentCompletionURLKey = "externalPaymentCompletionURL"
    
    static let didFinishRequestNotification = Notification.Name("didFinishRequest")
    static let finishedRequestStatusKey = "finishedRequestStatus"
    
    var paymentMethods: SectionedPaymentMethods?
    
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
        
        paymentController = PaymentController(delegate: self)
        paymentController?.start()
        requestStatus = .inProgress
        
        return true
    }
    
    func cancelRequest() {
        paymentController?.cancel()
    }
    
    func select(paymentMethod: PaymentMethod) {
        guard
            let publicKey = paymentController?.paymentSession?.publicKey,
            let generationDate = paymentController?.paymentSession?.generationDate else {
            return
        }
        
        let card = CardEncryptor.Card(
            number: cardDetails?.number,
            securityCode: cardDetails?.cvc,
            expiryMonth: cardDetails?.expiryMonth,
            expiryYear: cardDetails?.expiryYear
        )
        
        let encryptedCard = CardEncryptor.encryptedCard(for: card, publicKey: publicKey, generationDate: generationDate)
        
        var method = paymentMethod
        method.details.cardholderName?.value = cardDetails?.name
        method.details.encryptedCardNumber?.value = encryptedCard.number
        method.details.encryptedSecurityCode?.value = encryptedCard.securityCode
        method.details.encryptedExpiryMonth?.value = encryptedCard.expiryMonth
        method.details.encryptedExpiryYear?.value = encryptedCard.expiryYear
        
        paymentMethodCompletion?(method)
    }
    
    /**
     * Parameters:
     *      - name: cardholder name as String
     *      - number: card number as String
     *      - expiryDate: date as String in format MM/YY
     *      - cvc: cvc as String
     */
    func setCardDetailsForCurrentRequest(name: String, number: String, expiryDate: String, cvc: String, shouldSave: Bool) {
        guard expiryDate.count == 5 else {
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
        
        let cardNumber = cardDetails.number
        
        guard cardNumber.count > 4 else {
            return cardNumber
        }
        
        var replacementString = ""
        let numberOfCharactersToReplace = cardNumber.count - 4
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
    }
    
    internal var paymentController: PaymentController?
    private var paymentMethodCompletion: Completion<PaymentMethod>?
    private var cardDetails: CardDetails?
    private var requestStatus: RequestStatus = .none
    
    private let secretKey = "0101408667EE5CD5932B441CFA248497772C84EB96588A4314DE5E5D76428B4CAE8D72669BD57518C76F1214690BF3F3CC998122A6BC05A182EF9B833E6E5C17C53F3710C15D5B0DBEE47CDCB5588C48224C6007"
    
    private func postMainThreadNotification(_ notificationName: Notification.Name, userInfo: [AnyHashable: Any]? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: userInfo)
        }
    }
    
    private func clearStoredRequestData() {
        paymentController = nil
        paymentMethodCompletion = nil
        cardDetails = nil
        paymentMethods = nil
        requestStatus = .none
        authenticator = nil
        PaymentMethodImageCache.shared.removeAllObjects()
    }
    
    private var authenticator: Card3DS2Authenticator?
    
}

extension PaymentRequestManager: PaymentControllerDelegate {
    func requestPaymentSession(withToken token: String, for paymentController: PaymentController, responseHandler: @escaping (String) -> Void) {
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
            "token": token
        ]
        
        // For your convenience, we offer a test merchant server. Always use your own implementation when testing before going live.
        let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/paymentSession")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
        request.allHTTPHeaderFields = [
            "x-demo-server-api-key": secretKey,
            "Content-Type": "application/json"
        ]
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                paymentController.cancel()
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
    
    func selectPaymentMethod(from paymentMethods: SectionedPaymentMethods, for paymentController: PaymentController, selectionHandler: @escaping (PaymentMethod) -> Void) {
        self.paymentMethods = paymentMethods
        self.paymentMethodCompletion = selectionHandler
        postMainThreadNotification(PaymentRequestManager.didUpdatePaymentMethodsNotification)
    }
    
    func redirect(to url: URL, for paymentController: PaymentController) {
        let userInfo = [PaymentRequestManager.externalPaymentCompletionURLKey: url]
        postMainThreadNotification(PaymentRequestManager.didRequestExternalPaymentCompletionNotification, userInfo: userInfo)
    }
    
    func didFinish(with result: Result<PaymentResult>, for paymentController: PaymentController) {
        switch result {
        case let .success(payment):
            switch payment.status {
            case .received, .authorised, .pending:
                requestStatus = .success
            case .error, .refused:
                requestStatus = .failure
            case .cancelled:
                requestStatus = .cancelled
            }
        case let .failure(error):
            switch error {
            case PaymentController.Error.cancelled:
                requestStatus = .cancelled
            default:
                requestStatus = .failure
            }
        }
        
        let userInfo = [PaymentRequestManager.finishedRequestStatusKey: requestStatus]
        postMainThreadNotification(PaymentRequestManager.didFinishRequestNotification, userInfo: userInfo)
        clearStoredRequestData()
    }
    
    func provideAdditionalDetails(_ additionalDetails: AdditionalPaymentDetails, for paymentMethod: PaymentMethod, detailsHandler: @escaping Completion<[PaymentDetail]>) {
        guard paymentMethod.type == "card" else {
            detailsHandler([])
            return
        }
        
        if let identificationDetails = additionalDetails as? IdentificationPaymentDetails {
            handle3DS2Fingerprint(identificationDetails, detailsHandler: detailsHandler)
        } else if let challengeDetails = additionalDetails as? ChallengePaymentDetails {
            handle3DS2Challenge(challengeDetails, detailsHandler: detailsHandler)
        }
    }
    
    private func handle3DS2Fingerprint(_ identificationDetails: IdentificationPaymentDetails, detailsHandler: @escaping Completion<[PaymentDetail]>) {
        guard let fingerprintToken = identificationDetails.threeDS2FingerprintToken else { return }
        
        let authenticator = Card3DS2Authenticator()
        authenticator.createFingerprint(usingToken: fingerprintToken) { result in
            switch result {
            case let .success(fingerprint):
                var details = identificationDetails.details
                details.threeDS2Fingerprint?.value = fingerprint
                detailsHandler(details)
            case let .failure(error):
                print("An error occurred: \(error)")
                
                detailsHandler([])
            }
        }
        self.authenticator = authenticator
    }
    
    private func handle3DS2Challenge(_ challengeDetails: ChallengePaymentDetails, detailsHandler: @escaping Completion<[PaymentDetail]>) {
        guard let challengeToken = challengeDetails.threeDS2ChallengeToken else { return }
        
        authenticator?.presentChallenge(usingToken: challengeToken) { result in
            switch result {
            case let .success(challengeResult):
                var details = challengeDetails.details
                details.threeDS2ChallengeResult?.value = challengeResult.payload
                detailsHandler(details)
            case let .failure(error):
                print("An error occurred: \(error)")
                
                detailsHandler([])
            }
        }
    }
    
}
