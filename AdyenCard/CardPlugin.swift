//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

internal class CardPlugin: PaymentDetailsPlugin {
    
    internal let paymentSession: PaymentSession
    internal let paymentMethod: PaymentMethod
    
    internal weak static var cardScanDelegate: CardScanDelegate?
    
    internal required init(paymentSession: PaymentSession, paymentMethod: PaymentMethod) {
        self.paymentSession = paymentSession
        self.paymentMethod = paymentMethod
    }
    
    internal var canSkipPaymentMethodSelection: Bool {
        return true
    }
    
    internal var preferredPresentationMode: PaymentDetailsPluginPresentationMode {
        return .push
    }
    
    internal func viewController(for details: [PaymentDetail], appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) -> UIViewController {
        let amount = paymentSession.payment.amount(for: paymentMethod)
        
        let formViewController = CardFormViewController(appearance: appearance)
        formViewController.title = paymentMethod.name
        formViewController.paymentMethod = paymentMethod
        formViewController.paymentSession = paymentSession
        formViewController.payActionTitle = appearance.checkoutButtonAttributes.title(for: amount)
        
        if let surcharge = paymentMethod.surcharge, let amountString = AmountFormatter.formatted(amount: surcharge.total, currencyCode: amount.currencyCode) {
            formViewController.payActionSubtitle = ADYLocalizedString("surcharge.formatted", amountString)
        }
        
        if let delegate = CardPlugin.cardScanDelegate, delegate.isCardScanEnabled(for: paymentMethod) {
            formViewController.cardScanButtonHandler = { completion in
                delegate.scanCard(for: self.paymentMethod, completion: completion)
            }
        }
        
        formViewController.cardDetailsHandler = { cardInputData in
            var details = details
            details.encryptedCardNumber?.value = cardInputData.encryptedCard.number
            details.encryptedSecurityCode?.value = cardInputData.encryptedCard.securityCode
            details.encryptedExpiryYear?.value = cardInputData.encryptedCard.expiryYear
            details.encryptedExpiryMonth?.value = cardInputData.encryptedCard.expiryMonth
            details.installments?.value = cardInputData.installments
            details.storeDetails?.value = cardInputData.storeDetails.stringValue()
            details.cardholderName?.value = cardInputData.holderName
            
            completion(details)
        }
        
        return formViewController
    }
    
    private var authenticator: Card3DS2Authenticator?
    
}

// MARK: - AdditionalPaymentDetailsPlugin

extension CardPlugin: AdditionalPaymentDetailsPlugin {
    
    internal func present(_ additionalDetails: AdditionalPaymentDetails, using navigationController: UINavigationController, appearance: Appearance, completion: @escaping Completion<Result<[PaymentDetail]>>) {
        if let identificationDetails = additionalDetails as? IdentificationPaymentDetails {
            performIdentification(with: identificationDetails, completion: completion)
        } else if let challengeDetails = additionalDetails as? ChallengePaymentDetails {
            performChallenge(with: challengeDetails, completion: completion)
        }
    }
    
    private func performIdentification(with identificationDetails: IdentificationPaymentDetails, completion: @escaping Completion<Result<[PaymentDetail]>>) {
        guard let fingerprintToken = identificationDetails.threeDS2FingerprintToken else {
            completion(.failure(ThreeDS2Error.missingFingerprintToken))
            
            return
        }
        
        let authenticator = Card3DS2Authenticator()
        authenticator.createFingerprint(usingToken: fingerprintToken) { result in
            switch result {
            case let .success(fingerprint):
                var details = identificationDetails.details
                details.threeDS2Fingerprint?.value = fingerprint
                completion(.success(details))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
        self.authenticator = authenticator
    }
    
    private func performChallenge(with challengeDetails: ChallengePaymentDetails, completion: @escaping Completion<Result<[PaymentDetail]>>) {
        guard let challengeToken = challengeDetails.threeDS2ChallengeToken else {
            completion(.failure(ThreeDS2Error.missingChallengeToken))
            
            return
        }
        
        authenticator?.presentChallenge(usingToken: challengeToken) { result in
            switch result {
            case let .success(challengeResult):
                var details = challengeDetails.details
                details.threeDS2ChallengeResult?.value = challengeResult.payload
                completion(.success(details))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private enum ThreeDS2Error: Error {
        case missingFingerprintToken
        case missingChallengeToken
    }
    
}
