//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import AdyenCSE

internal class CardFormDetailsPresenter: PaymentDetailsPresenter {
    
    // MARK: - Public
    
    internal weak var delegate: PaymentDetailsPresenterDelegate?
    
    internal init(hostViewController: UINavigationController, pluginConfiguration: PluginConfiguration, appearanceConfiguration: AppearanceConfiguration, cardScanButtonHandler: ((@escaping CardScanCompletion) -> Void)?) {
        self.hostViewController = hostViewController
        self.pluginConfiguration = pluginConfiguration
        self.appearanceConfiguration = appearanceConfiguration
        self.cardScanButtonHandler = cardScanButtonHandler
    }
    
    internal func start() {
        let paymentMethod = pluginConfiguration.paymentMethod
        let paymentSetup = pluginConfiguration.paymentSetup
        let formattedAmount = CurrencyFormatter.format(paymentSetup.amount, currencyCode: paymentSetup.currencyCode)
        let inputDetails = paymentMethod.inputDetails
        
        let formViewController = CardFormViewController(appearanceConfiguration: appearanceConfiguration)
        formViewController.formattedAmount = formattedAmount
        formViewController.paymentMethod = paymentMethod
        formViewController.shouldHideStoreDetails = inputDetails?.filter({ $0.key == "storeDetails" }).count == 0
        formViewController.shouldHideInstallments = inputDetails?.filter({ $0.key == "installments" }).count == 0
        formViewController.shouldHideCVC = !paymentMethod.isCVCRequested
        
        formViewController.cardScanButtonHandler = cardScanButtonHandler
        formViewController.cardDetailsHandler = { cardInputData in
            self.submit(cardInputData: cardInputData)
        }
        hostViewController.pushViewController(formViewController, animated: true)
    }
    
    // MARK: - Private
    
    private let hostViewController: UINavigationController
    private let pluginConfiguration: PluginConfiguration
    private let appearanceConfiguration: AppearanceConfiguration
    private let cardScanButtonHandler: ((@escaping CardScanCompletion) -> Void)?
    
    private func submit(cardInputData: CardInputData) {
        let paymentDetails = PaymentDetails(details: pluginConfiguration.paymentMethod.inputDetails ?? [])
        
        if let token = cardInputData.token(with: pluginConfiguration.paymentSetup) {
            paymentDetails.fillCard(token: token, storeDetails: cardInputData.storeDetails)
        }
        
        if let installmentPlanIdentifier = cardInputData.installments {
            paymentDetails.fillCard(installmentPlanIdentifier: installmentPlanIdentifier)
        }
        
        delegate?.paymentDetailsPresenter(self, didSubmit: paymentDetails)
    }
    
}

// MARK: - CardInputData

internal extension CardInputData {
    
    internal func token(with paymentSetup: PaymentSetup) -> String? {
        guard let publicKey = paymentSetup.publicKey else {
            return nil
        }
        
        let card = ADYCard()
        card.generationtime = paymentSetup.generationDate
        card.holderName = holderName
        card.number = number
        card.expiryMonth = expiryMonth
        card.expiryYear = expiryYear
        card.cvc = cvc
        
        guard let encodedCard = card.encode() else {
            return nil
        }
        
        return ADYEncrypter.encrypt(encodedCard, publicKeyInHex: publicKey)
    }
    
}
