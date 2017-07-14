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
    }
    
    // MARK: - CheckoutPaymentFieldDelegate
    
    func paymentFieldChangedValidity(_ valid: Bool) {
        payButton.isEnabled = valid
    }
    
    func paymentFieldDidDetectCard(type: CardType) {
        updateCardLogoWith(type: type)
        updateCvcRequirementWith(type: type)
    }
    
    func paymentFieldDidUpdateActive(field: UITextField) {
        updateFieldsPresentationWith(field: field)
    }
    
    // MARK: - Public
    
    var cardDetailsHandler: (([String: Any], @escaping ((Bool) -> Void)) -> Void)?
    var formattedAmount: String?
    var paymentMethod: PaymentMethod?
    var shouldHideStoreDetails = false
    
    // MARK: - Private
    
    //  Interface Builder
    @IBOutlet private weak var lockImageView: UIImageView!
    
    //  Card Number Field
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardNumberLogoImageView: UIImageView!
    @IBOutlet private weak var cardNumberUnderlineView: UIView!
    @IBOutlet private weak var cardNumberTextField: CardNumberField!
    
    //  Expiry Date Field
    @IBOutlet private weak var expiryDateLabel: UILabel!
    @IBOutlet private weak var expiryDateUnderlineView: UIView!
    @IBOutlet private weak var expiryDateTextField: CardExpirationField!
    
    //  CVC Field
    @IBOutlet private weak var cvcLabel: UILabel!
    @IBOutlet private weak var cvcUnderlineView: UIView!
    @IBOutlet private weak var cvcTextField: CardCvcField!
    
    //  Store Details
    @IBOutlet private weak var storeDetailsLabel: UILabel!
    @IBOutlet private weak var storeDetailsButton: UIButton!
    
    @IBOutlet private weak var payButton: CheckoutButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var keyboardTopLineBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var formHeightConstraint: NSLayoutConstraint!
    
    private let inactiveColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
    private let activeColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
    
    private var cardFieldManager: CardPaymentFieldManager?
    private var detectedCardType: CardType?
    
    private let appearanceConfiguration: AppearanceConfiguration
    
    private func applyStyling() {
        title = ADYLocalizedString("creditCard.title")
        
        cardNumberLogoImageView.image = UIImage.bundleImage("credit_card_icon")
        lockImageView.image = UIImage.bundleImage("lock")
        storeDetailsButton.setImage(UIImage.bundleImage("checkbox_inactive"), for: .normal)
        storeDetailsButton.setImage(UIImage.bundleImage("checkbox_active"), for: .selected)
        storeDetailsButton.tintColor = appearanceConfiguration.tintColor
        
        payButton.isEnabled = false
        payButton.title = ADYLocalizedString("payButton.title.formatted", formattedAmount ?? "")
        payButton.appearanceConfiguration = appearanceConfiguration
        
        if shouldHideStoreDetails {
            hideStoreDetails()
        }
        
        cardNumberTextField.becomeFirstResponder()
        setupKeyboard()
        updateFieldsPresentationWith(field: cardNumberTextField)
    }
    
    private func hideStoreDetails() {
        storeDetailsLabel.isHidden = true
        storeDetailsButton.isHidden = true
        formHeightConstraint.constant -= 40
    }
    
    private func updateFieldsPresentationWith(field: UITextField) {
        cardNumberUnderlineView.backgroundColor = inactiveColor
        expiryDateUnderlineView.backgroundColor = inactiveColor
        cvcUnderlineView.backgroundColor = inactiveColor
        
        underlineViewFor(field)?.backgroundColor = activeColor
    }
    
    private func underlineViewFor(_ textField: UITextField) -> UIView? {
        var view: UIView?
        
        if cardNumberTextField == textField {
            view = cardNumberUnderlineView
        } else if expiryDateTextField == textField {
            view = expiryDateUnderlineView
        } else if cvcTextField == textField {
            view = cvcUnderlineView
        }
        
        return view
    }
    
    private func setupKeyboard() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        _ = NotificationCenter.default.addObserver(
            forName: .UIKeyboardWillShow,
            object: nil,
            queue: OperationQueue.main) { notification in
            
            guard
                let info = notification.userInfo,
                let bounds = info[UIKeyboardFrameEndUserInfoKey] as? CGRect
            else {
                return
            }
            
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bounds.size.height, right: 0)
            self.keyboardTopLineBottomConstraint.constant = bounds.size.height
        }
    }
    
    private func updateCardLogoWith(type: CardType?) {
        guard detectedCardType != type else {
            return
        }
        
        detectedCardType = type
        
        guard detectedCardType != nil else {
            cardNumberLogoImageView.image = UIImage.bundleImage("credit_card_icon")
            return
        }
        
        guard let members = paymentMethod?.members else {
            return
        }
        
        for member in members where member.type == detectedCardType!.rawValue {
            if let url = member.logoURL {
                cardNumberLogoImageView.downloadedFrom(url: url)
                cardNumberLogoImageView.contentMode = .scaleAspectFit
                cardNumberLogoImageView.layer.cornerRadius = 3
                cardNumberLogoImageView.clipsToBounds = true
                cardNumberLogoImageView.layer.borderWidth = 1 / UIScreen.main.nativeScale
                cardNumberLogoImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
            }
            
            return
        }
        
        //  change to unknown if couldn't find anything
        cardNumberLogoImageView.image = UIImage.bundleImage("credit_card_icon")
    }
    
    private func updateCvcRequirementWith(type: CardType?) {
        // TODO: update
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
        
        let dateComponents = expiryDate.replacingOccurrences(of: " ", with: "").components(separatedBy: "/")
        if dateComponents.count != 2 {
            return
        }
        
        let month = dateComponents[0]
        let year = "20" + dateComponents[1]
        
        let info: [String: Any] = [
            "number": number.replacingOccurrences(of: " ", with: ""),
            "expiryMonth": month,
            "expiryYear": year,
            "cvc": cvc,
            "storeDetails": storeDetailsButton.isSelected
        ]
        
        resignFirstResponder()
        
        cardNumberTextField.resignFirstResponder()
        expiryDateTextField.resignFirstResponder()
        cvcTextField.resignFirstResponder()
        
        payButton.isLoading = true
        
        cardDetailsHandler?(info) { success in }
    }
    
    @IBAction private func storeDetailsToggle(_ sender: Any) {
        storeDetailsButton.isSelected = !storeDetailsButton.isSelected
    }
    
}
