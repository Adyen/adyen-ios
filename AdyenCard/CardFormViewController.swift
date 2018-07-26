//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import QuartzCore
import UIKit

class CardFormViewController: FormViewController, CheckoutPaymentFieldDelegate {

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var acceptedCards: [CardType] = []
        
        if let paymentMethod = paymentMethod {
            // If the payment method represents a group of cards,
            // then acceptedCards should include all card types of its members.
            if paymentMethod.children.isEmpty == false {
                acceptedCards = paymentMethod.children.compactMap({ CardType(rawValue: $0.type) })
            } else if let cardType = CardType(rawValue: paymentMethod.type) {
                // Otherwise, we would expect only the card type associated with the payment method.
                acceptedCards = [cardType]
            }
        }
        
        if let holderNameField = holderNameField.textField as? CardHolderNameField,
            let numberTextField = numberField.textField as? CardNumberField,
            let expirationTextField = expiryDateField.textField as? CardExpirationField,
            let cvcTextField = cvcField.textField as? CardCvcField {
            cardFieldManager = CardPaymentFieldManager(holderNameField: holderNameField,
                                                       numberField: numberTextField,
                                                       expirationField: expirationTextField,
                                                       cvcField: cvcTextField,
                                                       acceptedCards: acceptedCards)
            cardFieldManager?.validTextColor = appearance.textAttributes[.foregroundColor] as? UIColor
            cardFieldManager?.invalidTextColor = appearance.formAttributes.invalidTextColor
            cardFieldManager?.isHolderNameRequired = holderNameConfiguration == .required
            cardFieldManager?.delegate = self
        }
        
        if let installmentsDetail = paymentMethod?.details.installments, case let .select(installments) = installmentsDetail.inputType {
            installmentItems = installments
        }
        
        formView.payButton.setTitle(ADYLocalizedString("payButton.formatted", formattedAmount ?? ""), for: .normal)
        formView.payButton.addTarget(self, action: #selector(pay), for: .touchUpInside)
        
        applyStyling()
        updateCvcRequirementAndVisibility()
    }
    
    // MARK: - CheckoutPaymentFieldDelegate
    
    func paymentFieldChangedValidity(_ valid: Bool) {
        formView.payButton.isEnabled = valid
    }
    
    func paymentFieldDidDetectCard(type: CardType?) {
        detectedCardType = type
    }
    
    // MARK: - Public
    
    var cardDetailsHandler: ((CardInputData) -> Void)?
    var cardScanButtonHandler: ((@escaping CardScanCompletion) -> Void)?
    var formattedAmount: String?
    var paymentSession: PaymentSession?
    var paymentMethod: PaymentMethod?
    var storeDetailsConfiguration: CardFormFieldConfiguration = .optional
    var installmentsConfiguration: CardFormFieldConfiguration = .optional
    var holderNameConfiguration: CardFormFieldConfiguration = .optional
    var cvcConfiguration: CardFormFieldConfiguration = .required
    
    // MARK: - Private
    
    private var cardFieldManager: CardPaymentFieldManager?
    private var installmentItems: [PaymentDetail.SelectItem]?
    
    private var detectedCardType: CardType? {
        didSet {
            if detectedCardType != oldValue {
                updateCardLogo()
                updateCvcRequirementAndVisibility()
            }
        }
    }
    
    private var paymentMethodForDetectedCardType: PaymentMethod? {
        guard let detectedCardType = detectedCardType else {
            return nil
        }
        
        // First check if the type matches the payment method.
        if paymentMethod?.type == detectedCardType.rawValue {
            return paymentMethod
        }
        
        guard let children = paymentMethod?.children else {
            return nil
        }
        
        // Then check if the type matches one of the members.
        for child in children where child.type == detectedCardType.rawValue {
            return child
        }
        
        return nil
    }
    
    private func applyStyling() {
        if cardScanButtonHandler != nil {
            navigationItem.rightBarButtonItem = cardNumberScanButton
        }
        
        if holderNameConfiguration != .none {
            formView.addFormElement(holderNameField)
        }
        
        formView.addFormElement(numberField)
        formView.addFormElement(expiryDateField)
        formView.addFormElement(cvcStackView)
        
        if installmentsConfiguration != .none {
            formView.addFormElement(installmentsField)
        }
        
        if storeDetailsConfiguration != .none {
            formView.addFormElement(storeDetailsView)
        }
    }
    
    private func updateCardLogo() {
        guard let detected = paymentMethodForDetectedCardType else {
            cardImageView.image = UIImage.bundleImage("credit_card_icon")
            cardImageView.layer.borderColor = UIColor.clear.cgColor
            return
        }
        
        let url = detected.logoURL
        cardImageView.downloadImage(from: url)
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.layer.cornerRadius = 3
        cardImageView.clipsToBounds = true
        cardImageView.layer.borderWidth = 1 / UIScreen.main.nativeScale
        cardImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
    }
    
    private func updateCvcRequirementAndVisibility() {
        // If CVC should always be hidden, don't bother with any CVC-specific logic.
        guard cvcConfiguration != .none else {
            cardFieldManager?.isCvcRequired = false
            cvcField.removeFromSuperview()
            cvcStackView.removeArrangedSubview(cvcField)
            return
        }
        
        guard let detectedPaymentMethod = paymentMethodForDetectedCardType else {
            cardFieldManager?.isCvcRequired = true
            cvcStackView.addArrangedSubview(cvcField)
            return
        }
        
        let detectedPaymentMethodConfiguration = CardFormFieldConfiguration.from(paymentDetail: detectedPaymentMethod.details.encryptedSecurityCode)
        
        cardFieldManager?.isCvcRequired = detectedPaymentMethodConfiguration == .required
        
        if detectedPaymentMethodConfiguration != .none {
            cvcStackView.addArrangedSubview(cvcField)
        } else {
            cvcField.removeFromSuperview()
            cvcStackView.removeArrangedSubview(cvcField)
        }
    }
    
    @objc private func pay() {
        // start animation
        guard
            let number = numberField.text,
            let expiryDate = expiryDateField.text,
            let cvc = cvcField.text,
            let publicKey = paymentSession?.publicKey,
            let generationDate = paymentSession?.generationDate
        else {
            return
        }
        
        let dateComponents = expiryDate.replacingOccurrences(of: " ", with: "").components(separatedBy: "/")
        let month = dateComponents[0]
        let year = "20" + dateComponents[1]
        
        let card = CardEncryptor.Card(number: number, securityCode: cvc, expiryMonth: month, expiryYear: year)
        let encryptedCard = CardEncryptor.encryptedCard(for: card, publicKey: publicKey, generationDate: generationDate)
        let installments = installmentItems?.filter({ $0.name == installmentsField.selectedValue }).first?.identifier
        
        let cardData = CardInputData(encryptedCard: encryptedCard, holderName: holderNameField.text, storeDetails: storeDetailsView.isSelected, installments: installments)
        
        view.endEditing(true)
        
        formView.payButton.showsActivityIndicator = true
        
        cardDetailsHandler?(cardData)
    }
    
    @objc private func scanCardClicked() {
        guard let cardScanButtonHandler = cardScanButtonHandler else {
            return
        }
        
        let completion: CardScanCompletion = { [weak self] scannedCard in
            DispatchQueue.main.async {
                self?.cardFieldManager?.set(text: scannedCard.number, inField: self?.numberField.textField)
                self?.cardFieldManager?.set(text: scannedCard.expiryDate, inField: self?.expiryDateField.textField)
                self?.cardFieldManager?.set(text: scannedCard.securityCode, inField: self?.cvcField.textField)
                self?.cardFieldManager?.set(text: scannedCard.holderName, inField: self?.holderNameField.textField)
                
                let cardNumberIsEmpty = self?.numberField.text?.isEmpty ?? true
                if cardNumberIsEmpty {
                    self?.numberField.textField.becomeFirstResponder()
                } else {
                    let expiryIsEmpty = self?.expiryDateField.text?.isEmpty ?? true
                    if expiryIsEmpty {
                        self?.expiryDateField.textField.becomeFirstResponder()
                    } else {
                        self?.cvcField.textField.becomeFirstResponder()
                    }
                    
                }
            }
        }
        cardScanButtonHandler(completion)
    }
    
    private lazy var holderNameField: FormField = {
        let nameField = FormField(textFieldClass: CardHolderNameField.self)
        nameField.title = ADYLocalizedString("creditCard.holderNameField.title")
        nameField.placeholder = ADYLocalizedString("creditCard.holderNameField.placeholder")
        nameField.accessibilityIdentifier = "holder-name-field"
        nameField.textField.autocapitalizationType = .words
        nameField.textField.autocorrectionType = .no
        
        return nameField
    }()
    
    private lazy var numberField: FormField = {
        let numberField = FormField(textFieldClass: CardNumberField.self)
        numberField.title = ADYLocalizedString("creditCard.numberField.title")
        numberField.placeholder = ADYLocalizedString("creditCard.numberField.placeholder")
        numberField.accessibilityIdentifier = "number-field"
        numberField.textField.keyboardType = .numberPad
        numberField.accessoryView = cardImageView
        
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
    
    private lazy var expiryDateField: FormField = {
        let expiryDateField = FormField(textFieldClass: CardExpirationField.self)
        expiryDateField.title = ADYLocalizedString("creditCard.expiryDateField.title")
        expiryDateField.placeholder = ADYLocalizedString("creditCard.expiryDateField.placeholder")
        expiryDateField.textField.keyboardType = .numberPad
        expiryDateField.accessibilityIdentifier = "expiry-date-field"
        
        return expiryDateField
    }()
    
    private lazy var cvcField: FormField = {
        let cvcField = FormField(textFieldClass: CardCvcField.self)
        cvcField.title = ADYLocalizedString("creditCard.cvcField.title")
        cvcField.placeholder = ADYLocalizedString("creditCard.cvcField.placeholder")
        cvcField.textField.keyboardType = .numberPad
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
        let constraints = [
            imageView.widthAnchor.constraint(equalToConstant: 38.0),
            imageView.heightAnchor.constraint(equalToConstant: 24.0)
        ]
        NSLayoutConstraint.activate(constraints)
        
        return imageView
    }()
    
    private lazy var cardNumberScanButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(scanCardClicked))
        button.tintColor = appearance.tintColor
        return button
    }()
    
    private lazy var installmentsField: FormPicker = {
        let picker = FormPicker(values: installmentItems!.map { $0.name })
        picker.title = ADYLocalizedString("creditCard.installmentsField")
        
        return picker
    }()
}
