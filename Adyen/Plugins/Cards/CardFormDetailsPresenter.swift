//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import AdyenCSE

internal class CardFormDetailsPresenter: PaymentDetailsPresenter {

    var navigationMode: NavigationMode = .push
    var forceHidingStoreDetails: Bool = true

    // MARK: - Public
    
    internal weak var delegate: PaymentDetailsPresenterDelegate?
    
    internal init(hostViewController: UINavigationController, pluginConfiguration: PluginConfiguration, cardScanButtonHandler: ((@escaping CardScanCompletion) -> Void)?) {
        self.hostViewController = hostViewController
        self.pluginConfiguration = pluginConfiguration
        self.cardScanButtonHandler = cardScanButtonHandler
    }
    
    internal func start() {
        let paymentMethod = pluginConfiguration.paymentMethod
        let paymentSetup = pluginConfiguration.paymentSetup
        
        let inputDetails = paymentMethod.inputDetails
        
        let formViewController = CardFormViewController()
        formViewController.title = paymentMethod.name
        formViewController.payButtonTitle = AppearanceConfiguration.shared.payActionTitle(forAmount: paymentSetup.amount, currencyCode: paymentSetup.currencyCode)
        formViewController.paymentMethod = paymentMethod
        formViewController.shouldHideStoreDetails = forceHidingStoreDetails || inputDetails?.filter({ $0.key == "storeDetails" }).count == 0
        formViewController.shouldHideInstallments = inputDetails?.filter({ $0.key == "installments" }).count == 0
        formViewController.shouldHideCVC = !paymentMethod.isCVCRequested
        
        formViewController.cardScanButtonHandler = cardScanButtonHandler
        formViewController.cardDetailsHandler = { cardInputData in
            self.submit(cardInputData: cardInputData)
        }
        
        present(formViewController)
    }

    private func present(_ viewController: UIViewController) {
        switch navigationMode {
        case .present:
            hostViewController.viewControllers = [viewController]
            viewController.navigationItem.hidesBackButton = true
            viewController.navigationItem.leftBarButtonItem = AppearanceConfiguration.shared.cancelButtonItem(target: self, selector: #selector(didSelect(cancelButtonItem:)))
        case .push:
            hostViewController.pushViewController(viewController, animated: true)
        }
    }

    @objc private func didSelect(cancelButtonItem: Any) {
        hostViewController.dismiss(animated: true, completion: nil)
    }

    // MARK: - Private
    
    private let hostViewController: UINavigationController
    private let pluginConfiguration: PluginConfiguration
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
