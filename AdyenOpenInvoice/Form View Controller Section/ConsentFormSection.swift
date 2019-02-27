//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

class ConsentFormSection: OpenInvoiceFormSection {
    
    // MARK: - Internal
    
    init(paymentMethodType: String, validityCallback: @escaping () -> Void) {
        self.paymentMethodType = paymentMethodType
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
    private var paymentMethodType: String
    
    private lazy var consentLabel: FormLabel = {
        let label = FormLabel()
        label.accessibilityIdentifier = "consent-label"
        
        let attributedTitle = NSMutableAttributedString(string: termsAndConditions)
        
        attributedTitle.string.rangesOf(subString: underlinedString).forEach({ range in
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
    
    private lazy var termsAndConditions: String = {
        switch paymentMethodType {
        case "klarna":
            return ADYLocalizedString("klarna.consentCheckbox", underlinedString)
        case "afterpay_default":
            return ADYLocalizedString("afterPay.agreement", underlinedString)
        default:
            return ""
        }
    }()
    
    private lazy var underlinedString: String = {
        switch paymentMethodType {
        case "klarna":
            return ADYLocalizedString("klarna.consent")
        case "afterpay_default":
            return ADYLocalizedString("afterPay.paymentConditions")
        default:
            return ""
        }
    }()
    
    private lazy var klarnaConsentURLString: String = {
        "https://cdn.klarna.com/1.0/shared/content/legal/terms/2/de_de/consent"
    }()
    
    private lazy var afterPayConsentURLString: String = {
        switch (NSLocale.current.languageCode, NSLocale.current.regionCode) {
        case ("nl", "BE"):
            return "https://www.afterpay.be/be/footer/betalen-met-afterpay/betalingsvoorwaarden"
        case ("nl", _):
            return "https://www.afterpay.nl/nl/algemeen/betalen-met-afterpay/betalingsvoorwaarden"
        default:
            return "https://www.afterpay.nl/en/algemeen/pay-with-afterpay/payment-conditions"
        }
    }()
    
    private func didTouchConsentLabel() {
        guard paymentMethodType == "klarna" || paymentMethodType == "afterpay_default" else {
            return
        }
        
        let urlString = paymentMethodType == "klarna" ? klarnaConsentURLString : afterPayConsentURLString
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
