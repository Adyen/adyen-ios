//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

class ConsentFormSection: OpenInvoiceFormSection {
    
    // MARK: - Internal
    
    init(validityCallback: @escaping () -> Void) {
        self.validityCallback = validityCallback
        super.init()
        
        title = ADYLocalizedString("openInvoice.termsAndConditionsSection.title")
        
        addFormElement(consentLabel)
        addFormElement(consentView)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func isValid() -> Bool {
        return consentView.isSelected
    }
    
    // MARK: - Private
    
    private var validityCallback: () -> Void
    
    private lazy var consentLabel: FormLabel = {
        let label = FormLabel()
        label.accessibilityIdentifier = "consent-label"
        
        let consentString = ADYLocalizedString("klarna.consent")
        let attributedTitle = NSMutableAttributedString(string: ADYLocalizedString("klarna.consentCheckbox", consentString))
        
        attributedTitle.string.rangesOf(subString: consentString).forEach({ range in
            attributedTitle.addAttribute(NSAttributedString.Key.underlineStyle, value: 1.0, range: range)
        })
        
        label.attributedTitle = attributedTitle
        
        label.onLabelTap = { [weak self] in
            self?.didTouchConsentLabel()
        }
        
        return label
    }()
    
    private lazy var consentView: FormConsentView = {
        let view = FormConsentView()
        view.title = ADYLocalizedString("openInvoice.agreeToTermsAndConditionsLabel")
        view.isSelected = false
        view.accessibilityIdentifier = "consent-button"
        
        view.onValueChanged = { [weak self] isOn in
            self?.validityCallback()
        }
        
        return view
    }()
    
    private func didTouchConsentLabel() {
        if let url = URL(string: "https://cdn.klarna.com/1.0/shared/content/legal/terms/2/de_de/consent") {
            UIApplication.shared.openURL(url)
        }
    }
}

private extension String {
    func rangesOf(subString: String) -> [NSRange] {
        var ranges = [NSRange]()
        
        var range: NSRange = NSRange(location: 0, length: self.count)
        while range.location != NSNotFound {
            range = (self as NSString).range(of: subString, options: .caseInsensitive, range: range)
            if range.location != NSNotFound {
                ranges.append(range)
                range = NSRange(location: range.location + range.length, length: self.count - (range.location + range.length))
            }
        }
        return ranges
    }
}
