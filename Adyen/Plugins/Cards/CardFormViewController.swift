//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import QuartzCore

class CardFormViewController: UIViewController, CheckoutPaymentFieldDelegate {
    
    // MARK: - Object Lifecycle
    
    init(appearanceConfiguration: AppearanceConfiguration) {
        self.appearanceConfiguration = appearanceConfiguration
        
        super.init(nibName: "CardFormViewController", bundle: Bundle(for: CardFormViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyling()
        
        let acceptedCards = paymentMethod?.members?.flatMap({ CardType(rawValue: $0.type) }) ?? []
        cardFieldManager = CardPaymentFieldManager(numberField: cardNumberTextField, expirationField: expiryDateTextField, cvcField: cvcTextField, acceptedCards: acceptedCards)
        cardFieldManager?.delegate = self
        
        if let installments = paymentMethod?.inputDetails?.filter({ $0.key == "installments" }).first?.items {
            installmentItems = installments
            cardFieldManager?.enableInstalments(textField: installmentTextField, values: installments)
        }
    }
    
    // MARK: - CheckoutPaymentFieldDelegate
    
    func paymentFieldChangedValidity(_ valid: Bool) {
        payButton.isEnabled = valid
    }
    
    func paymentFieldDidDetectCard(type: CardType?) {
        detectedCardType = type
    }
    
    func paymentFieldDidUpdateActive(field: UITextField) {
        updateFieldsPresentationWith(field: field)
    }
    
    // MARK: - Public
    
    var cardDetailsHandler: ((CardInputData) -> Void)?
    var cardScanButtonHandler: ((@escaping CardScanCompletion) -> Void)?
    var formattedAmount: String?
    var paymentMethod: PaymentMethod?
    var shouldHideStoreDetails = false
    var shouldHideInstallments = false
    
    // MARK: - Private
    
    //  Card Number Field
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardNumberLogoImageView: UIImageView!
    @IBOutlet private weak var cardNumberUnderlineView: UIView!
    @IBOutlet private weak var cardNumberTextField: CardNumberField!
    @IBOutlet private weak var cardNumberScanButton: UIButton!
    @IBOutlet private weak var cardNumberWidthConstraint: NSLayoutConstraint!
    
    //  Expiry Date Field
    @IBOutlet private weak var expiryDateLabel: UILabel!
    @IBOutlet private weak var expiryDateUnderlineView: UIView!
    @IBOutlet private weak var expiryDateTextField: CardExpirationField!
    
    //  CVC Field
    @IBOutlet private weak var cvcLabel: UILabel!
    @IBOutlet private weak var cvcUnderlineView: UIView!
    @IBOutlet private weak var cvcTextField: CardCvcField!
    
    //  Store Details
    @IBOutlet private weak var storeDetailsView: UIView!
    @IBOutlet private weak var storeDetailsLabel: UILabel!
    @IBOutlet private weak var storeDetailsButton: UIButton!
    
    @IBOutlet weak var installmentUnderlineView: UIView!
    @IBOutlet weak var installmentsView: UIView!
    @IBOutlet weak var installmentTextField: CardInstallmentField!
    
    @IBOutlet private weak var payButton: CheckoutButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var keyboardTopLineBottomConstraint: NSLayoutConstraint!
    
    private let inactiveColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
    private let activeColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
    private let appearanceConfiguration: AppearanceConfiguration
    
    private var cardFieldManager: CardPaymentFieldManager?
    private var installmentItems: [InputSelectItem]?
    
    private var detectedCardType: CardType? {
        didSet {
            if detectedCardType != oldValue {
                updateCardLogo()
                updateCvcRequirement()
            }
        }
    }
    
    private func applyStyling() {
        title = ADYLocalizedString("creditCard.title")
        
        if cardScanButtonHandler == nil {
            cardNumberWidthConstraint.constant = 0
        }
        cardNumberScanButton.setImage(UIImage.bundleImage("camera_icon"), for: UIControlState())
        
        cardNumberLogoImageView.image = UIImage.bundleImage("credit_card_icon")
        storeDetailsButton.setImage(UIImage.bundleImage("checkbox_inactive"), for: .normal)
        storeDetailsButton.setImage(UIImage.bundleImage("checkbox_active"), for: .selected)
        storeDetailsButton.tintColor = appearanceConfiguration.tintColor
        
        payButton.isEnabled = false
        payButton.title = ADYLocalizedString("payButton.formatted", formattedAmount ?? "")
        payButton.appearanceConfiguration = appearanceConfiguration
        
        storeDetailsView.isHidden = shouldHideStoreDetails
        installmentsView.isHidden = shouldHideInstallments
        
        cardNumberTextField.becomeFirstResponder()
        setupKeyboard()
        updateFieldsPresentationWith(field: cardNumberTextField)
    }
    
    private func updateFieldsPresentationWith(field: UITextField) {
        cardNumberUnderlineView.backgroundColor = inactiveColor
        expiryDateUnderlineView.backgroundColor = inactiveColor
        cvcUnderlineView.backgroundColor = inactiveColor
        installmentUnderlineView.backgroundColor = inactiveColor
        
        underlineViewFor(field)?.backgroundColor = activeColor
    }
    
    private func underlineViewFor(_ textField: UITextField) -> UIView? {
        if cardNumberTextField == textField {
            return cardNumberUnderlineView
        } else if expiryDateTextField == textField {
            return expiryDateUnderlineView
        } else if cvcTextField == textField {
            return cvcUnderlineView
        } else if installmentTextField == textField {
            return installmentUnderlineView
        }
        
        return nil
    }
    
    private func setupKeyboard() {
        _ = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { notification in
            if let bounds = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bounds.size.height, right: 0)
                self.keyboardTopLineBottomConstraint.constant = bounds.size.height
            }
        }
    }
    
    private func updateCardLogo() {
        guard let detectedCardType = detectedCardType, let members = paymentMethod?.members else {
            cardNumberLogoImageView.image = UIImage.bundleImage("credit_card_icon")
            return
        }
        
        for member in members where member.type == detectedCardType.rawValue {
            if let url = member.logoURL {
                cardNumberLogoImageView.downloadImage(from: url)
                cardNumberLogoImageView.contentMode = .scaleAspectFit
                cardNumberLogoImageView.layer.cornerRadius = 3
                cardNumberLogoImageView.clipsToBounds = true
                cardNumberLogoImageView.layer.borderWidth = 1 / UIScreen.main.nativeScale
                cardNumberLogoImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
            }
            
            return
        }
        
        // Change to unknown if couldn't find anything.
        cardNumberLogoImageView.image = UIImage.bundleImage("credit_card_icon")
    }
    
    private func updateCvcRequirement() {
        guard let detectedCardType = detectedCardType, let members = paymentMethod?.members else {
            cardFieldManager?.isCvcRequired = true
            return
        }
        
        for member in members where member.type == detectedCardType.rawValue {
            if let details = member.inputDetails {
                for detail in details {
                    switch detail.type {
                    case let .cardToken(cvcOptional):
                        cardFieldManager?.isCvcRequired = !cvcOptional
                        return
                    default:
                        break
                    }
                }
            }
        }
        
        cardFieldManager?.isCvcRequired = true
    }
    
    @IBAction private func pay(_ sender: Any) {
        // start animation
        guard
            let number = cardNumberTextField.text,
            let expiryDate = expiryDateTextField.text,
            let cvc = cvcTextField.text
        else {
            return
        }
        
        let installments = installmentItems?.filter({ $0.name == installmentTextField?.text }).first?.identifier
        
        let cardData = CardInputData(
            number: number,
            expiryDate: expiryDate,
            cvc: cvc,
            storeDetails: storeDetailsButton.isSelected,
            installments: installments)
        
        resignFirstResponder()
        
        cardNumberTextField.resignFirstResponder()
        expiryDateTextField.resignFirstResponder()
        cvcTextField.resignFirstResponder()
        
        payButton.isLoading = true
        
        cardDetailsHandler?(cardData)
    }
    
    @IBAction private func storeDetailsToggle(_ sender: Any) {
        storeDetailsButton.isSelected = !storeDetailsButton.isSelected
    }
    
    @IBAction private func scanCardClicked(_ sender: Any) {
        guard let cardScanButtonHandler = cardScanButtonHandler else {
            return
        }
        
        let completion: CardScanCompletion = { [weak self] scannedCard in
            DispatchQueue.main.async {
                self?.cardFieldManager?.set(text: scannedCard.number, inField: self?.cardNumberTextField)
                self?.cardFieldManager?.set(text: scannedCard.expiryDate, inField: self?.expiryDateTextField)
                self?.cardFieldManager?.set(text: scannedCard.cvc, inField: self?.cvcTextField)
                
                let cardNumberIsEmpty = self?.cardNumberTextField.text?.isEmpty ?? true
                if cardNumberIsEmpty {
                    self?.cardNumberTextField.becomeFirstResponder()
                } else {
                    let expiryIsEmpty = self?.expiryDateTextField.text?.isEmpty ?? true
                    if expiryIsEmpty {
                        self?.expiryDateTextField.becomeFirstResponder()
                    } else {
                        self?.cvcTextField.becomeFirstResponder()
                    }
                    
                }
            }
        }
        cardScanButtonHandler(completion)
    }
    
}
