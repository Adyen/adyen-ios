//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import QuartzCore

class CardFormViewController: UIViewController {
    //  Interface Builder
    @IBOutlet weak var lockImageView: UIImageView!
    
    //  Card Number Field
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cardNumberLogoImageView: UIImageView!
    @IBOutlet weak var cardNumberUnderlineView: UIView!
    @IBOutlet weak var cardNumberTextField: CardNumberField!
    
    //  Expiry Date Field
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var expiryDateUnderlineView: UIView!
    @IBOutlet weak var expiryDateTextField: CardExpirationField!
    
    //  CVC Field
    @IBOutlet weak var cvcLabel: UILabel!
    @IBOutlet weak var cvcUnderlineView: UIView!
    @IBOutlet weak var cvcTextField: CardCvcField!
    
    //  Store Details
    @IBOutlet weak var storeDetailsLabel: UILabel!
    @IBOutlet weak var storeDetailsButton: UIButton!
    
    @IBOutlet weak var payButton: CheckoutButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var keyboardTopLineBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var formHeightConstraint: NSLayoutConstraint!
    
    fileprivate let inactiveColor = UIColor(hexString: "D8D8D8")
    fileprivate let activeColor = UIColor(hexString: "757575")
    
    fileprivate var cardFieldManager: CardPaymentFieldManager?
    fileprivate var detectedCardType = CardType.unknown
    
    var cardDetailsHandler: (([String: Any], @escaping ((Bool) -> Void)) -> Void)?
    var formattedAmount: String?
    var paymentMethod: PaymentMethod?
    var shouldHideStoreDetails = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyling()
        
        let acceptedCards = paymentMethod?.members?.flatMap({ CardType(rawValue: $0.type) }) ?? []
        cardFieldManager = CardPaymentFieldManager(numberField: cardNumberTextField, expirationField: expiryDateTextField, cvcField: cvcTextField, acceptedCards: acceptedCards)
        cardFieldManager?.delegate = self
    }
    
    private func applyStyling() {
        title = "Card Details"
        
        cardNumberLogoImageView.image = UIImage.bundleImage("credit_card_icon")
        lockImageView.image = UIImage.bundleImage("lock")
        storeDetailsButton.setImage(UIImage.bundleImage("checkbox_inactive"), for: .normal)
        storeDetailsButton.setImage(UIImage.bundleImage("checkbox_active"), for: .selected)
        
        payButton.isEnabled = false
        payButton.layer.cornerRadius = 4
        payButton.setTitle("Pay \(formattedAmount ?? "")", for: .normal)
        
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
    
    fileprivate func updateFieldsPresentationWith(field: UITextField) {
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
    
    fileprivate func updateCardLogoWith(type: CardType) {
        if detectedCardType == type {
            return
        }
        
        detectedCardType = type
        
        if detectedCardType == .unknown {
            cardNumberLogoImageView.image = UIImage.bundleImage("credit_card_icon")
            return
        }
        
        guard let members = paymentMethod?.members else {
            return
        }
        
        for member in members where member.type == detectedCardType.rawValue {
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
}

extension CardFormViewController {
    @IBAction func pay(_ sender: Any) {
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
        
        cardNumberTextField.resignFirstResponder()
        expiryDateTextField.resignFirstResponder()
        cvcTextField.resignFirstResponder()
        
        payButton.startLoading()
        
        cardDetailsHandler?(info) { success in }
    }
    
    @IBAction func storeDetailsToggle(_ sender: Any) {
        storeDetailsButton.isSelected = !storeDetailsButton.isSelected
    }
}

extension CardFormViewController: CheckoutPaymentFieldDelegate {
    
    func paymentFieldChangedValidity(_ valid: Bool) {
        payButton.isEnabled = valid
    }
    
    func paymentFieldDidDetectCard(type: CardType) {
        updateCardLogoWith(type: type)
    }
    
    func paymentFieldDidUpdateActive(field: UITextField) {
        updateFieldsPresentationWith(field: field)
    }
}
