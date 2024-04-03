//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

extension XCTestCase {
    
    internal func populate(textItemView: some FormTextItemView<some FormTextItem>, with text: String) {
        let textView = textItemView.textField
        textView.text = text
        textView.sendActions(for: .editingChanged)
    }
    
    internal func populateSimulatingKeystrokes(textItemView: some FormTextItemView<some FormTextItem>, with text: String, betweenStrokesInterval: DispatchTimeInterval = .milliseconds(5)) {
        let textView = textItemView.textField
        for char in text {
            textView.text?.append(char)
            wait(for: betweenStrokesInterval)
            textView.sendActions(for: .editingChanged)
        }
    }
    
    internal func populate(textItemView: (some FormTextItemView<some FormTextItem>)?, with text: String) {
        guard let textItemView else { return }
        populate(textItemView: textItemView, with: text)
    }

    internal func append(textItemView: some FormTextItemView<some FormTextItem>, with text: String) {
        let textView = textItemView.textField
        textView.text = (textView.text ?? "") + text
        textView.sendActions(for: .editingChanged)
    }
    
    internal func getRandomCurrencyCode() -> String {
        NSLocale.isoCurrencyCodes.randomElement() ?? "EUR"
    }
    
    internal func getRandomCountryCode() -> String {
        NSLocale.isoCountryCodes.randomElement() ?? "DE"
    }
}
