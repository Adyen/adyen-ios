//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import QuartzCore
import UIKit

class CardFormViewController: FormViewController {
    
    // MARK: - FormViewController
    
    internal override func pay() {
        guard
            let number = numberField.text,
            let expiryDate = expiryDateField.text,
            let cvc = cvcField.text,
            let publicKey = paymentSession?.publicKey,
            let generationDate = paymentSession?.generationDate
        else {
            return
        }
        
        super.pay()
        
        let dateComponents = expiryDate.replacingOccurrences(of: " ", with: "").components(separatedBy: "/")
        let month = dateComponents[0]
        let year = "20" + dateComponents[1]
        
        let card = CardEncryptor.Card(number: number, securityCode: cvc, expiryMonth: month, expiryYear: year)
        let encryptedCard = CardEncryptor.encryptedCard(for: card, publicKey: publicKey, generationDate: generationDate)
        let installments = installmentItems?.filter({ $0.name == installmentsField.selectedValue }).first?.identifier
        
        let cardData = CardInputData(encryptedCard: encryptedCard, holderName: holderNameField.text, storeDetails: storeDetailsView.isSelected, installments: installments)
        
        cardDetailsHandler?(cardData)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if cardScanButtonHandler != nil {
            navigationItem.rightBarButtonItem = cardNumberScanButton
        }
        
        if holderNameConfiguration != .none {
            formView.addFormElement(holderNameField)
        }
        
        formView.addFormElement(numberField)
        formView.addFormElement(expiryDateField)
        
        if cvcConfiguration != .none {
            formView.addFormElement(cvcStackView)
        }
        
        if installmentsConfiguration != .none {
            formView.addFormElement(installmentsField)
        }
        
        if storeDetailsConfiguration != .none {
            formView.addFormElement(storeDetailsView)
        }
        
        formView.payButton.addTarget(self, action: #selector(pay), for: .touchUpInside)
    }
    
    // MARK: - Public
    
    var cardDetailsHandler: ((CardInputData) -> Void)?
    var cardScanButtonHandler: ((@escaping CardScanCompletion) -> Void)?
    var paymentSession: PaymentSession?
    var paymentMethod: PaymentMethod? {
        didSet {
            guard let paymentMethod = paymentMethod else {
                return
            }
            
            // If the payment method represents a group, acceptedCards should include all card types of its members.
            if paymentMethod.children.isEmpty == false {
                acceptedCards = paymentMethod.children.compactMap({ CardType(rawValue: $0.type) })
            } else if let cardType = CardType(rawValue: paymentMethod.type) {
                // Otherwise, we would expect only the card type associated with the payment method.
                acceptedCards = [cardType]
            }
            
            storeDetailsConfiguration = CardFormFieldConfiguration.from(paymentDetail: paymentMethod.details.storeDetails)
            installmentsConfiguration = CardFormFieldConfiguration.from(paymentDetail: paymentMethod.details.installments)
            holderNameConfiguration = CardFormFieldConfiguration.from(paymentDetail: paymentMethod.details.cardholderName)
            
            if let installmentsDetail = paymentMethod.details.installments,
                case let .select(installments) = installmentsDetail.inputType {
                installmentItems = installments
            }
        }
    }
    
    // MARK: - Private
    
    private var installmentItems: [PaymentDetail.SelectItem]?
    private var acceptedCards: [CardType] = []
    
    private var storeDetailsConfiguration: CardFormFieldConfiguration = .optional
    private var installmentsConfiguration: CardFormFieldConfiguration = .optional
    private var holderNameConfiguration: CardFormFieldConfiguration = .optional
    
    private var cvcConfiguration: CardFormFieldConfiguration {
        if let paymentMethodForDetectedCardType = paymentMethodForDetectedCardType {
            return CardFormFieldConfiguration.from(paymentDetail: paymentMethodForDetectedCardType.details.encryptedSecurityCode)
        }
        
        if let paymentMethod = paymentMethod {
            return CardFormFieldConfiguration.from(paymentDetail: paymentMethod.details.encryptedSecurityCode)
        }
        
        return .required
    }
    
    private var detectedCardType: CardType? {
        didSet {
            if detectedCardType != oldValue {
                updateCardLogo()
                updateCvcVisibility()
            }
        }
    }
    
    private var paymentMethodForDetectedCardType: PaymentMethod? {
        guard let detectedCardType = detectedCardType, let paymentMethod = paymentMethod else {
            return nil
        }
        
        // Check the payment method and all its children for a match
        let allPaymentMethods = [paymentMethod] + paymentMethod.children
        return allPaymentMethods.first(where: { $0.type == detectedCardType.rawValue })
    }
    
    private lazy var holderNameField: FormTextField = {
        let nameField = FormTextField()
        nameField.delegate = self
        nameField.validator = CardNameValidator()
        nameField.title = ADYLocalizedString("creditCard.holderNameField.title")
        nameField.placeholder = ADYLocalizedString("creditCard.holderNameField.placeholder")
        nameField.accessibilityIdentifier = "holder-name-field"
        nameField.autocapitalizationType = .words
        nameField.nextResponderInChain = numberField
        return nameField
    }()
    
    private lazy var numberField: FormTextField = {
        let numberField = FormTextField()
        numberField.delegate = self
        numberField.keyboardType = .numberPad
        numberField.validator = CardNumberValidator()
        numberField.title = ADYLocalizedString("creditCard.numberField.title")
        numberField.placeholder = ADYLocalizedString("creditCard.numberField.placeholder")
        numberField.accessibilityIdentifier = "number-field"
        numberField.accessoryView = cardImageView
        numberField.nextResponderInChain = expiryDateField
        return numberField
    }()
    
    private lazy var cvcStackView: UIStackView = {
        // This is a stack view so that the cvc field can be easily added/removed.
        let stackView = UIStackView()
        stackView.spacing = 22.0
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(cvcField)
        return stackView
    }()
    
    private lazy var expiryDateField: FormTextField = {
        let expiryDateField = FormTextField()
        expiryDateField.delegate = self
        expiryDateField.keyboardType = .numberPad
        expiryDateField.validator = CardExpiryValidator()
        expiryDateField.title = ADYLocalizedString("creditCard.expiryDateField.title")
        expiryDateField.placeholder = ADYLocalizedString("creditCard.expiryDateField.placeholder")
        expiryDateField.accessibilityIdentifier = "expiry-date-field"
        expiryDateField.nextResponderInChain = cvcField
        return expiryDateField
    }()
    
    private lazy var cvcField: FormTextField = {
        let cvcField = FormTextField()
        cvcField.delegate = self
        cvcField.keyboardType = .numberPad
        cvcField.validator = CardSecurityCodeValidator()
        cvcField.title = ADYLocalizedString("creditCard.cvcField.title")
        cvcField.placeholder = ADYLocalizedString("creditCard.cvcField.placeholder")
        cvcField.accessibilityIdentifier = "cvc-field"
        return cvcField
    }()
    
    private lazy var storeDetailsView: FormConsentView = {
        let view = FormConsentView()
        view.title = ADYLocalizedString("creditCard.storeDetailsButton")
        view.isSelected = false
        view.accessibilityIdentifier = "store-details-button"
        return view
    }()
    
    private lazy var cardImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.bundleImage("credit_card_icon"))
        imageView.frame = CGRect(x: 0, y: 0, width: 38, height: 24)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 3
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1 / UIScreen.main.nativeScale
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    
    private lazy var cardNumberScanButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(scanCardClicked))
        button.tintColor = appearance.tintColor
        return button
    }()
    
    private lazy var installmentsField: FormSelectField = {
        let selectField = FormSelectField(values: installmentItems!.map { $0.name })
        selectField.title = ADYLocalizedString("creditCard.installmentsField")
        
        return selectField
    }()
    
    private func updateCardType() {
        guard let cardNumber = numberField.text, let validator = numberField.validator as? CardNumberValidator else {
            return
        }
        
        let sanitizedCardNumber = validator.sanitize(cardNumber)
        let cardType = acceptedCards.first { $0.matches(cardNumber: sanitizedCardNumber) }
        detectedCardType = cardType
    }
    
    private func updateValidity() {
        var valid = false
        
        if holderNameField.validatedValue != nil || holderNameConfiguration != .required,
            cvcField.validatedValue != nil || cvcConfiguration != .required,
            numberField.validatedValue != nil,
            expiryDateField.validatedValue != nil {
            valid = true
        }
        
        isValid = valid
    }
    
    private func updateCardLogo() {
        guard let url = paymentMethodForDetectedCardType?.logoURL else {
            cardImageView.image = UIImage.bundleImage("credit_card_icon")
            cardImageView.layer.borderColor = UIColor.clear.cgColor
            return
        }
        
        cardImageView.downloadImage(from: url)
        cardImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
    }
    
    private func updateCvcVisibility() {
        if cvcConfiguration == .none {
            cvcField.removeFromSuperview()
            cvcStackView.removeArrangedSubview(cvcField)
        } else {
            cvcStackView.addArrangedSubview(cvcField)
        }
    }
}

extension CardFormViewController: FormTextFieldDelegate {
    func valueChanged(_ formTextField: FormTextField) {
        if formTextField == numberField {
            updateCardType()
        }
        
        updateValidity()
    }
}

// MARK: - Scan Card

extension CardFormViewController {
    @objc private func scanCardClicked() {
        guard let cardScanButtonHandler = cardScanButtonHandler else {
            return
        }
        
        let completion: CardScanCompletion = { [weak self] scannedCard in
            DispatchQueue.main.async {
                self?.numberField.text = scannedCard.number
                self?.expiryDateField.text = scannedCard.expiryDate
                self?.cvcField.text = scannedCard.securityCode
                self?.holderNameField.text = scannedCard.holderName
                
                let nameIsEmpty = self?.holderNameField.text?.isEmpty ?? true
                let cardNumberIsEmpty = self?.numberField.text?.isEmpty ?? true
                let expiryIsEmpty = self?.expiryDateField.text?.isEmpty ?? true
                
                if nameIsEmpty, self?.holderNameConfiguration != .none {
                    _ = self?.holderNameField.becomeFirstResponder()
                } else if cardNumberIsEmpty {
                    _ = self?.numberField.becomeFirstResponder()
                } else if expiryIsEmpty {
                    _ = self?.expiryDateField.becomeFirstResponder()
                } else {
                    _ = self?.cvcField.becomeFirstResponder()
                }
                
                self?.updateValidity()
            }
        }
        cardScanButtonHandler(completion)
    }
}
