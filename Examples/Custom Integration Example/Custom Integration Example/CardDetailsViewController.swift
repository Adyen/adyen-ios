//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

class CardDetailsViewController: PaymentDetailsViewController, UITextFieldDelegate {
    
    // MARK: - Object Lifecycle
    
    override init(withPaymentMethod method: PaymentMethod, paymentController: PaymentController) {
        super.init(withPaymentMethod: method, paymentController: paymentController)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustLayoutForKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PaymentDetailsViewController
    
    override func submit() {
        // For the purpose of this demo, do not perform validation
        if let name = validatedName(nameTextField.text),
            let number = validatedCardNumber(cardNumberTextField.text),
            let expiryDate = validatedExpiry(expiryTextField.text),
            let cvc = validatedCvc(cvcTextField.text) {
            PaymentRequestManager.shared.setCardDetailsForCurrentRequest(name: name, number: number, expiryDate: expiryDate, cvc: cvc, shouldSave: saveSwitch.isOn)
            let confirmation = PaymentConfirmationViewController(withPaymentMethod: paymentMethod, paymentController: paymentController)
            navigationController?.pushViewController(confirmation, animated: false)
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = "card details"
        
        populateForm()
        layoutForm()
        
        nameTextField.becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        // We want to listen to shake gestures.
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            populateFieldsWithFakeData()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        if textField == self.cvcTextField {
            if newString.count > 4 {
                return false
            }
        } else if textField == self.cardNumberTextField {
            if newString.count > 19 {
                return false
            }
        } else if textField == self.expiryTextField {
            if newString.count > 5 {
                return false
            }
            
            if currentString.length == 2 && newString.count == 3 {
                textField.text = (currentString as String) + "/"
            } else if newString.count == 3 && currentString.length == 4 {
                textField.text = currentString.replacingOccurrences(of: "/", with: "")
            }
        }
        
        return true
    }
    
    // MARK: - Private
    
    private var keyboardHeightOnScreen: CGFloat = 0.0
    private let fieldInset: CGFloat = 39.0
    
    private let nameTextField = UITextField(frame: .zero)
    private let cardNumberTextField = UITextField(frame: .zero)
    private let expiryTextField = UITextField(frame: .zero)
    private let cvcTextField = UITextField(frame: .zero)
    private let saveSwitch = UISwitch(frame: .zero)
    
    private func validatedName(_ name: String?) -> String? {
        guard let name = name else {
            return nil
        }
        
        return name.count > 0 ? name : nil
    }
    
    private func validatedCardNumber(_ number: String?) -> String? {
        return number
    }
    
    private func validatedExpiry(_ expiry: String?) -> String? {
        return expiry
    }
    
    private func validatedCvc(_ cvc: String?) -> String? {
        return cvc
    }
    
    private lazy var nameTextFieldContainer: UIView = {
        self.nameTextField.placeholder = "Enter name"
        self.nameTextField.autocorrectionType = .no
        let containerView = self.textFieldContainerView(for: self.nameTextField, prompt: "Name on card")
        return containerView
    }()
    
    private lazy var cardNumberTextFieldContainer: UIView = {
        self.cardNumberTextField.placeholder = "Enter card number"
        self.cardNumberTextField.keyboardType = .numberPad
        let containerView = self.textFieldContainerView(for: self.cardNumberTextField, prompt: "Card number")
        return containerView
    }()
    
    private lazy var expiryTextFieldContainer: UIView = {
        self.expiryTextField.placeholder = "MM/YY"
        self.expiryTextField.keyboardType = .numberPad
        let containerView = self.textFieldContainerView(for: self.expiryTextField, prompt: "Expiry date")
        return containerView
    }()
    
    private lazy var cvcTextFieldContainer: UIView = {
        self.cvcTextField.placeholder = "---"
        self.cvcTextField.keyboardType = .numberPad
        let containerView = self.textFieldContainerView(for: self.cvcTextField, prompt: "CVC")
        return containerView
    }()
    
    private lazy var saveCardContainer: UIView = {
        let containerView = UIView(frame: .zero)
        return containerView
    }()
    
    private func textFieldContainerView(for textField: UITextField, prompt: String) -> UIView {
        let promptBaselineOffsetFromTop: CGFloat = 35.0
        let textFieldBaselineOffsetFromTop: CGFloat = 25.0
        
        var frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0)
        let containerView = UIView(frame: frame)
        
        let promptLabel = UILabel(frame: .zero)
        promptLabel.font = Theme.standardFontSmall
        promptLabel.text = prompt
        promptLabel.textColor = Theme.primaryColor
        promptLabel.sizeToFit()
        containerView.addSubview(promptLabel)
        
        frame.origin.x = self.fieldInset
        frame.size.width = frame.width - 2 * self.fieldInset
        frame.size.height = promptLabel.frame.size.height
        frame.origin.y = promptBaselineOffsetFromTop - frame.height + promptLabel.font.descender
        promptLabel.frame = frame
        promptLabel.autoresizingMask = .flexibleWidth
        
        textField.font = Theme.textFieldFont
        textField.textColor = Theme.secondaryColor
        textField.delegate = self
        containerView.addSubview(textField)
        
        textField.sizeToFit()
        frame.size.height = textField.frame.size.height
        frame.origin.y = promptLabel.frame.maxY - promptLabel.font.descender + textFieldBaselineOffsetFromTop - frame.height + textField.font!.descender
        textField.frame = frame
        textField.autoresizingMask = .flexibleWidth
        
        frame.origin.x = 0.0
        frame.size.width = containerView.bounds.size.width
        frame.size.height = 1.0 / UIScreen.main.scale
        frame.origin.y = containerView.bounds.height - frame.height
        let dividerView = UIView(frame: frame)
        dividerView.backgroundColor = Theme.headerFooterBackgroundColor
        dividerView.autoresizingMask = .flexibleTopMargin
        containerView.addSubview(dividerView)
        
        return containerView
    }
    
    private lazy var saveMethodSwitchContainerView: UIView = {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 0))
        
        container.addSubview(self.saveSwitch)
        
        var frame = CGRect.zero
        frame.size = self.saveSwitch.bounds.size
        frame.origin.x = container.bounds.width - frame.width - self.fieldInset
        self.saveSwitch.frame = frame
        self.saveSwitch.onTintColor = Theme.primaryColor
        
        frame = container.bounds
        frame.origin.x = self.fieldInset
        frame.size.width = self.saveSwitch.frame.minX - self.fieldInset - 10.0
        
        let prompt = UILabel(frame: frame)
        prompt.text = "Save card for future checkouts?"
        prompt.font = Theme.textFieldFont
        prompt.textColor = Theme.secondaryColor
        prompt.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        container.addSubview(prompt)
        return container
    }()
    
    private func populateFieldsWithFakeData() {
        nameTextField.text = "Checkout Shopper"
        cardNumberTextField.text = "5555444433331111"
        expiryTextField.text = "08/18"
        cvcTextField.text = "737"
    }
    
    private func populateForm() {
        formScrollView.addSubview(nameTextFieldContainer)
        formScrollView.addSubview(cardNumberTextFieldContainer)
        formScrollView.addSubview(expiryTextFieldContainer)
        formScrollView.addSubview(cvcTextFieldContainer)
        formScrollView.addSubview(saveMethodSwitchContainerView)
    }
    
    private func layoutForm() {
        let availableHeight: CGFloat = view.bounds.height - keyboardHeightOnScreen - navigationBar.bounds.height - submitButton.bounds.height
        let fieldHeight: CGFloat = availableHeight / 4
        
        var frame = nameTextFieldContainer.frame
        frame.size.height = fieldHeight
        nameTextFieldContainer.frame = frame
        
        frame = nameTextFieldContainer.frame
        frame.origin.y = nameTextFieldContainer.frame.maxY
        cardNumberTextFieldContainer.frame = frame
        
        frame.origin.y = cardNumberTextFieldContainer.frame.maxY
        frame.size.width = view.bounds.size.width / 2.0
        expiryTextFieldContainer.frame = frame
        
        frame.origin.x = frame.maxX
        cvcTextFieldContainer.frame = frame
        
        frame = saveMethodSwitchContainerView.frame
        frame.size.height = fieldHeight
        frame.origin.y = cvcTextFieldContainer.frame.maxY
        saveMethodSwitchContainerView.frame = frame
        
        frame = saveSwitch.frame
        frame.origin.y = fieldHeight / 2 - frame.size.height / 2
        saveSwitch.frame = frame
        
        frame = submitButton.frame
        frame.origin.y = saveMethodSwitchContainerView.frame.maxY
        submitButton.frame = frame
    }
    
    @objc private func adjustLayoutForKeyboard(notification: NSNotification) {
        if let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeightOnScreen = frame.height
            layoutForm()
        }
    }
    
}
