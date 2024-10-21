//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class FormCardNumberItemTests: XCTestCase {

    var apiClient: APIClientMock!
    var publicKeyProvider: PublicKeyProviderMock!
    let supportedCardTypes: [CardType] = [.visa, .masterCard, .americanExpress, .chinaUnionPay, .maestro]
    var cardBrandProvider: BinInfoProvider!

    override func setUp() {
        apiClient = APIClientMock()
        publicKeyProvider = PublicKeyProviderMock()
        cardBrandProvider = BinInfoProvider(
            apiClient: apiClient,
            publicKeyProvider: publicKeyProvider,
            minBinLength: 11,
            binLookupType: .card
        )
    }

    override func tearDown() {
        apiClient = nil
        publicKeyProvider = nil
        cardBrandProvider = nil
    }

    func testInternalBinLookup() {

        let cardTypeLogos = supportedCardTypes.map {
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://google.com")!, type: $0)
        }
        let item = FormCardNumberItem(cardTypeLogos: cardTypeLogos)
        XCTAssertEqual(item.cardTypeLogos.count, 5)
        
        let visa = item.cardTypeLogos[0]
        let mc = item.cardTypeLogos[1]
        let amex = item.cardTypeLogos[2]
        let cup = item.cardTypeLogos[3]
        let maestro = item.cardTypeLogos[4]
        
        // Initially, only placeholder should be visible
        XCTAssertEqual(item.detectedBrandLogos.count, 0)
        
        // When typing unknown combination, still show placeholder
        item.value = "5"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 0)
        }
        
        // When typing Maestro pattern, only Maestro should be visible.
        item.value = "56"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 1)
            XCTAssertEqual(item.detectedBrandLogos[0], maestro)
        }
        
        // When typing Mastercard pattern, only Mastercard should be visible.
        item.value = "55"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 1)
            XCTAssertEqual(item.detectedBrandLogos[0], mc)
        }
        
        // When continuing to type, Mastercard should remain visible.
        item.value = "5555"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 1)
            XCTAssertEqual(item.detectedBrandLogos[0], mc)
        }
        
        // Clearing the field should bring back placeholder
        item.value = ""
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 0)
        }
        
        // When typing VISA pattern, only VISA should be visible.
        item.value = "4"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 1)
            XCTAssertEqual(item.detectedBrandLogos[0], visa)
        }
        
        // When typing Amex pattern, only Amex should be visible.
        item.value = "34"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 1)
            XCTAssertEqual(item.detectedBrandLogos[0], amex)
        }
        
        // When typing common pattern, all matching cards should be visible.
        item.value = "62"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 2)
            XCTAssertEqual(item.detectedBrandLogos[0], cup)
            XCTAssertEqual(item.detectedBrandLogos[1], maestro)
        }
    }

    func testExternalBinLookupHappyFlow() {
        publicKeyProvider.onFetch = { $0(.success("SOME_PUBLIC_KEY")) }
        let mockedBrands = [CardBrand(type: .masterCard)]
        apiClient.mockedResults = [
            .success(BinLookupResponse(brands: mockedBrands)),
            .success(BinLookupResponse(brands: []))
        ]

        let cardTypeLogos = supportedCardTypes.map {
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://google.com")!, type: $0)
        }
        let item = FormCardNumberItem(cardTypeLogos: cardTypeLogos)
        XCTAssertEqual(item.cardTypeLogos.count, 5)

        item.value = "1234567890"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 0)
        }
    }

    func testExternalBinLookupFallback() {
        publicKeyProvider.onFetch = { $0(.success("SOME_PUBLIC_KEY")) }
        apiClient.mockedResults = [.failure(Dummy.error), .failure(Dummy.error)]

        let cardTypeLogos = supportedCardTypes.map {
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://google.com")!, type: $0)
        }
        let item = FormCardNumberItem(cardTypeLogos: cardTypeLogos)
        XCTAssertEqual(item.cardTypeLogos.count, 5)

        // When entering PAN, Mastercard should remain visible.
        item.value = "5577000055770004"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 1)
            XCTAssertEqual(item.detectedBrandLogos[0].type, .masterCard)
        }

        // When entering too long PAN, all logos should be hidden.
        item.value = "55770000557700040"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            item.update(brands: response.brands!)
            XCTAssertEqual(item.detectedBrandLogos.count, 0)
        }
    }
    
    func testLocalizationWithCustomTableName() {
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let sut = FormCardNumberItem(cardTypeLogos: [], localizationParameters: expectedLocalizationParameters)
        
        XCTAssertEqual(sut.title, localizedString(.cardNumberItemTitle, expectedLocalizationParameters))
        XCTAssertEqual(sut.placeholder, localizedString(.cardNumberItemPlaceholder, expectedLocalizationParameters))
        XCTAssertEqual(sut.validationFailureMessage, localizedString(.cardNumberItemInvalid, expectedLocalizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let sut = FormCardNumberItem(cardTypeLogos: [], localizationParameters: expectedLocalizationParameters)
        
        XCTAssertEqual(sut.title, localizedString(LocalizationKey(key: "adyen_card_numberItem_title"), expectedLocalizationParameters))
        XCTAssertEqual(sut.placeholder, localizedString(LocalizationKey(key: "adyen_card_numberItem_placeholder"), expectedLocalizationParameters))
        XCTAssertEqual(sut.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_numberItem_invalid"), expectedLocalizationParameters))
    }
    
    func testCursorMovement() throws {
        
        let textField = UITextField()
        textField.becomeFirstResponder()
        
        let item = FormCardNumberItem(cardTypeLogos: [])
        
        /// 1234 56|31 0
        /// 1234 567|3 10 // Adding 7 -> move 1 to the right
        /// 1234 5678 |310 // Adding 8 -> move 2 to the right
        /// 1234 5678 9|310 // Adding 9 -> move 1 to the right
        /// 1234 5678| 310 // Removing 9 -> move 2 to the left
        /// 1234 567|3 10 // Removing 8 -> move 1 to the left
        /// 1234 56|31 0 // Removing 7 -> move 1 to the left
        
        // Adding a character
        
        textField.text = ""
        textField.selectedTextRange = UITextRange.textRange(startOffset: 0, in: textField)
        XCTAssertEqual(item.textField(textField, shouldChangeCharactersIn: .init(location: 0, length: 0), replacementString: "1"), false)
        XCTAssertEqual(textField.text, "1")
        XCTAssertEqual(textField.selectedTextRange, UITextRange.textRange(startOffset: 1, in: textField))
        
        textField.text = "1234"
        textField.selectedTextRange = UITextRange.textRange(startOffset: 4, in: textField)
        XCTAssertEqual(item.textField(textField, shouldChangeCharactersIn: .init(location: 4, length: 0), replacementString: "5"), false)
        XCTAssertEqual(textField.text, "1234 5")
        XCTAssertEqual(textField.selectedTextRange, UITextRange.textRange(startOffset: 6, in: textField))
        
        // Removing a character
        
        textField.text = "1"
        textField.selectedTextRange = UITextRange.textRange(startOffset: 1, in: textField)
        XCTAssertEqual(item.textField(textField, shouldChangeCharactersIn: .init(location: 0, length: 1), replacementString: ""), false)
        XCTAssertEqual(textField.text, "")
        XCTAssertEqual(textField.selectedTextRange, UITextRange.textRange(startOffset: 0, in: textField))
        
        textField.text = "1234 5"
        textField.selectedTextRange = UITextRange.textRange(startOffset: 6, in: textField)
        XCTAssertEqual(item.textField(textField, shouldChangeCharactersIn: .init(location: 5, length: 1), replacementString: ""), false)
        XCTAssertEqual(textField.text, "1234")
        XCTAssertEqual(textField.selectedTextRange, UITextRange.textRange(startOffset: 4, in: textField))
        
        // Replacing multiple characters with 1 (1234 56 -> 1239 6)
        
        textField.text = "1234 56"
        textField.selectedTextRange = UITextRange.textRange(startOffset: 6, in: textField)
        XCTAssertEqual(item.textField(textField, shouldChangeCharactersIn: .init(location: 3, length: 3), replacementString: "9"), false)
        XCTAssertEqual(textField.text, "1239 6")
        XCTAssertEqual(textField.selectedTextRange, UITextRange.textRange(startOffset: 4, in: textField))
        
        // Replacing 1 character with multiple (1234 56 -> 1234 9996)
        
        textField.text = "1234 56"
        textField.selectedTextRange = UITextRange.textRange(startOffset: 6, in: textField)
        XCTAssertEqual(item.textField(textField, shouldChangeCharactersIn: .init(location: 5, length: 1), replacementString: "999"), false)
        XCTAssertEqual(textField.text, "1234 9996")
        XCTAssertEqual(textField.selectedTextRange, UITextRange.textRange(startOffset: 8, in: textField))
        
        // Manually moving cursor to after a space and deleting
        
        textField.text = "1234 56"
        textField.selectedTextRange = UITextRange.textRange(startOffset: 5, in: textField)
        XCTAssertEqual(item.textField(textField, shouldChangeCharactersIn: .init(location: 4, length: 1), replacementString: ""), false)
        XCTAssertEqual(textField.text, "1234 56")
        XCTAssertEqual(textField.selectedTextRange, UITextRange.textRange(startOffset: 4, in: textField))
    }
    
}

// MARK: - Helper Extensions

private extension UITextField {
    func cursorOffset() throws -> Int {
        let rangeEnd = try XCTUnwrap(selectedTextRange?.end)
        return offset(from: beginningOfDocument, to: rangeEnd)
    }
}

private extension UITextRange {
    
    static func textRange(from start: UITextPosition, to end: UITextPosition, in textField: UITextField) -> UITextRange {
        textField.textRange(from: start, to: end)!
    }
    
    static func textRange(from start: UITextPosition, length: Int = 0, in textField: UITextField) -> UITextRange {
        let end = textField.position(from: start, offset: length)!
        return Self.textRange(from: start, to: end, in: textField)
    }
    
    static func textRange(startOffset: Int, length: Int = 0, in textField: UITextField) -> UITextRange {
        let start = textField.position(from: textField.beginningOfDocument, offset: startOffset)!
        let end = textField.position(from: start, offset: length)!
        return Self.textRange(from: start, to: end, in: textField)
    }
}
