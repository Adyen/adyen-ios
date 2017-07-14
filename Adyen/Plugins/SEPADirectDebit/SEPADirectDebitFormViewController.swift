//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class SEPADirectDebitFormViewController: UIViewController {
    
    internal init(appearanceConfiguration: AppearanceConfiguration) {
        self.appearanceConfiguration = appearanceConfiguration
        
        super.init(nibName: "SEPADirectDebitFormViewController", bundle: Bundle(for: SEPADirectDebitFormViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal weak var delegate: SEPADirectDebitFormViewControllerDelegate?
    
    internal var formattedAmount = ""
    
    private let appearanceConfiguration: AppearanceConfiguration
    
    // MARK: View
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var lockView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lockView.image = UIImage.bundleImage("lock")
        checkmarkButton.setImage(UIImage.bundleImage("checkbox_inactive"), for: .normal)
        checkmarkButton.setImage(UIImage.bundleImage("checkbox_active"), for: .selected)
        checkmarkButton.tintColor = appearanceConfiguration.tintColor
        
        payButton.title = ADYLocalizedString("payButton.title.formatted", formattedAmount)
        payButton.appearanceConfiguration = appearanceConfiguration
        payButton.isEnabled = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isEditing == false {
            ibanField.becomeFirstResponder()
        }
    }
    
    // MARK: Text Fields
    
    @IBOutlet private weak var ibanField: IBANTextField!
    
    @IBOutlet private weak var ibanUnderlineView: UIView!
    
    private var name: String {
        return nameField.text ?? ""
    }
    
    @IBOutlet private weak var nameField: UITextField!
    
    @IBOutlet private weak var nameUnderlineView: UIView!
    
    @IBAction private func textFieldDidChange() {
        revalidate()
    }
    
    @IBAction private func textFieldDidBeginEditing(_ textField: UITextField) {
        underlineView(for: textField)?.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
    }
    
    @IBAction private func textFieldDidEndEditing(_ textField: UITextField) {
        underlineView(for: textField)?.backgroundColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let bounds = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        scrollView.contentInset.bottom = bounds.height
        scrollView.scrollIndicatorInsets.bottom = bounds.height
    }
    
    private func underlineView(for textField: UITextField) -> UIView? {
        if textField === ibanField {
            return ibanUnderlineView
        } else if textField === nameField {
            return nameUnderlineView
        }
        
        return nil
    }
    
    // MARK: Checkmark Button
    
    @IBOutlet private weak var checkmarkButton: UIButton!
    
    @IBAction private func didSelect(checkmarkButton: UIButton) {
        checkmarkButton.isSelected = !checkmarkButton.isSelected
        
        revalidate()
    }
    
    // MARK: Pay Button
    
    @IBOutlet private weak var payButton: CheckoutButton!
    
    @IBAction private func didSelect(payButton: CheckoutButton) {
        guard let iban = ibanField.iban else {
            return
        }
        
        delegate?.formViewController(self, didSubmitWithIBAN: iban, name: name)
    }
    
    // MARK: Validation
    
    private var isValid: Bool {
        guard checkmarkButton.isSelected else {
            return false
        }
        
        guard ibanField.iban != nil else {
            return false
        }
        
        guard name.characters.count > 0 else {
            return false
        }
        
        return true
    }
    
    fileprivate func revalidate() {
        payButton.isEnabled = isValid
    }
    
    // MARK: Loading
    
    internal var isLoading = false {
        didSet {
            if isLoading {
                setEditing(false, animated: true)
            }
            
            payButton.isLoading = isLoading
        }
    }
    
}
