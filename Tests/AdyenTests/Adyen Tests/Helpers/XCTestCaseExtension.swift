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
    
    func populate<T: FormTextItem, U: FormTextItemView<T>>(textItemView: U, with text: String) {
        let textView = textItemView.textField
        textView.text = text
        textView.sendActions(for: .editingChanged)
    }
    
    func populate<T: FormTextItem, U: FormTextItemView<T>>(textItemView: U?, with text: String) {
        guard let textItemView = textItemView else { return }
        populate(textItemView: textItemView, with: text)
    }

    func append<T: FormTextItem, U: FormTextItemView<T>>(textItemView: U, with text: String) {
        let textView = textItemView.textField
        textView.text = (textView.text ?? "") + text
        textView.sendActions(for: .editingChanged)
    }
    
    func getRandomCurrencyCode() -> String {
        NSLocale.isoCurrencyCodes.randomElement() ?? "EUR"
    }
    
    func getRandomCountryCode() -> String {
        NSLocale.isoCountryCodes.randomElement() ?? "DE"
    }
    
    func asyncAfterDelay(seconds: Int = 1, execute work: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: work)
    }

}
