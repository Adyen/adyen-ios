//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

/// A text field object designed for the entry of an IBAN value. This field formats and validates the IBAN in real time.
internal class IBANTextField: UITextField {

    // MARK: - Initializing
    
    /// :nodoc:
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    /// :nodoc:
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    // MARK: - Accessing Validated Input
    
    /// The IBAN entered in the text field, or `nil` if no valid IBAN has been entered.
    internal var iban: String? {
        guard let text = text else {
            return nil
        }
        
        guard IBANValidator.isValid(text) else {
            return nil
        }
        
        return text
    }
    
    // MARK: - Internal
    
    var validTextColor: UIColor?
    
    var invalidTextColor: UIColor?
    
    // MARK: - Private
    
    private func configure() {
        autocapitalizationType = .allCharacters
        autocorrectionType = .no
        
        addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        configurePlaceholder()
    }
    
    private func configurePlaceholder() {
        var exampleIBAN: String!
        
        if let countryCode = Locale.current.regionCode, let specification = IBANSpecification(forCountryCode: countryCode) {
            exampleIBAN = specification.example
        } else {
            exampleIBAN = IBANSpecification(forCountryCode: "NL")!.example
        }
        
        placeholder = exampleIBAN.grouped(length: 4)
    }
    
    @objc private func editingDidBegin() {
        updateTextColor()
    }
    
    @objc private func editingDidEnd() {
        updateTextColor()
    }
    
    @objc private func textDidChange() {
        formatText()
    }
    
    private func formatText() {
        let text = IBANValidator.canonicalize(self.text ?? "")
        self.text = text.grouped(length: 4)
    }
    
    private func updateTextColor() {
        if isEditing {
            textColor = validTextColor
        } else {
            textColor = (iban != nil) ? validTextColor : invalidTextColor
        }
    }
    
}
