//
//  XCTestCaseExtension.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 3/18/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenEncryption
import XCTest

extension XCTestCase {
    
    internal func populate(textItemView: some FormTextItemView<some FormTextItem>, with text: String) {
        let textView = textItemView.textField
        textView.text = text
        textView.sendActions(for: .editingChanged)
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
    
    internal func asyncAfterDelay(seconds: Int = 1, execute work: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: work)
    }

}
