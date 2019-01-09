//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

class SocialSecurityNumberSection: OpenInvoiceFormSection {
    
    // MARK: - Internal
    
    lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    init(ssnCallback: @escaping (String) -> Void) {
        self.ssnCallback = ssnCallback
        super.init()
        
        title = ADYLocalizedString("openInvoice.ssnSection.title")
        
        addFormElement(socialSecurityNumberField)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private var ssnCallback: (String) -> Void
    
    private lazy var socialSecurityNumberField: FormTextField = {
        let ssnField = FormTextField()
        ssnField.validator = KlarnaSSNValidator()
        ssnField.title = ""
        ssnField.placeholder = "YY MM DD NNNN"
        ssnField.accessibilityIdentifier = "social-security-number-field"
        ssnField.keyboardType = .numberPad
        ssnField.accessoryView = activityIndicator
        ssnField.delegate = self
        ssnField.clearButtonMode = .never
        return ssnField
    }()
    
}

extension SocialSecurityNumberSection: FormTextFieldDelegate {
    
    func valueChanged(_ formTextField: FormTextField) {
        if formTextField == socialSecurityNumberField, let validated = formTextField.validatedValue {
            let sanitized = validated.replacingOccurrences(of: " ", with: "")
            ssnCallback(sanitized[0...5] + "-" + sanitized[6..<sanitized.count])
        }
    }
}
