//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class FormCardSecurityCodeItemViewTests: XCTestCase {

    var sut: FormCardSecurityCodeItemView!
    var item: FormCardSecurityCodeItem!
    var validator: CardSecurityCodeValidator!
    var formatter: CardSecurityCodeFormatter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        item = FormCardSecurityCodeItem()
        validator = CardSecurityCodeValidator()
        formatter = CardSecurityCodeFormatter()

        item.validator = validator
        item.formatter = formatter
        sut = FormCardSecurityCodeItemView(item: item)
    }

    override func tearDownWithError() throws {
        validator = nil
        formatter = nil
        item = nil
        sut = nil
        try super.tearDownWithError()
    }

    func test_textFieldSanitization_givenNonAllowedCharacters_shouldSanitizeAndFormatInput() {
        // Given
        let expectedCVV = "458"
        let expectedFormattedCVV = formatter.formattedValue(for: expectedCVV)

        // When
        sut.textField.text = "45d8"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertEqual(expectedCVV, item.value)
        XCTAssertEqual(expectedFormattedCVV, item.formattedValue)
        XCTAssertEqual(expectedFormattedCVV, sut.textField.text)
        XCTAssertEqual(sut.textField.allowsEditingActions, false)
    }

    func test_textFieldSanitization_givenCorrectSecurityCode_shouldSanitizeAndFormatInput() {
        // Given
        let expectedCVV = "917"
        let expectedFormattedCVV = formatter.formattedValue(for: expectedCVV)

        // When
        sut.textField.text = "917"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertEqual(expectedCVV, item.value)
        XCTAssertEqual(expectedFormattedCVV, item.formattedValue)
        XCTAssertEqual(expectedFormattedCVV, sut.textField.text)
    }

    func test_shouldChangeCharacters_givenNonAmexAndInputExceedsThreeDigits_shouldReject() {
        // Given
        sut.textField.text = "123"

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 3, length: 0),
            replacementString: "4"
        )

        // Then
        XCTAssertFalse(shouldChange)
    }

    func test_shouldChangeCharacters_givenNonAmexAndInputWithinThreeDigits_shouldAllow() {
        // Given
        sut.textField.text = "12"

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 2, length: 0),
            replacementString: "3"
        )

        // Then
        XCTAssertTrue(shouldChange)
    }

    func test_shouldChangeCharacters_givenAmexAndInputWithinFourDigits_shouldAllow() {
        // Given
        item.selectedCard = .americanExpress
        sut.textField.text = "123"

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 3, length: 0),
            replacementString: "4"
        )

        // Then
        XCTAssertTrue(shouldChange)
    }

    func test_shouldChangeCharacters_givenAmexAndInputExceedsFourDigits_shouldReject() {
        // Given
        item.selectedCard = .americanExpress
        sut.textField.text = "1234"

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 4, length: 0),
            replacementString: "5"
        )

        // Then
        XCTAssertFalse(shouldChange)
    }

    func test_shouldChangeCharacters_givenDeletion_shouldAlwaysAllow() {
        // Given
        sut.textField.text = "123"

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 2, length: 1),
            replacementString: ""
        )

        // Then
        XCTAssertTrue(shouldChange)
    }

    func test_pasting_givenNonAmexAndMoreThanMaxDigits_shouldAllowAndTruncateValue() {
        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "1234"
        )
        sut.textField.text = "1234"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertTrue(shouldChange)
        XCTAssertEqual(item.value, "123")
        XCTAssertTrue(item.isValid())
    }

    func test_pasting_givenNonAmexAndValidLength_shouldAllowAndSetValue() {
        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "123"
        )
        sut.textField.text = "123"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertTrue(shouldChange)
        XCTAssertEqual(item.value, "123")
        XCTAssertTrue(item.isValid())
    }

    func test_pasting_givenAmexAndValidLength_shouldAllowAndSetValue() {
        // Given
        item.formatter = CardSecurityCodeFormatter(publisher: item.$selectedCard)
        item.validator = CardSecurityCodeValidator(publisher: item.$selectedCard)
        item.selectedCard = .americanExpress

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "1234"
        )
        sut.textField.text = "1234"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertTrue(shouldChange)
        XCTAssertEqual(item.value, "1234")
        XCTAssertTrue(item.isValid())
    }

    func test_pasting_givenAmexAndMoreThanMaxDigits_shouldAllowAndTruncateValue() {
        // Given
        item.formatter = CardSecurityCodeFormatter(publisher: item.$selectedCard)
        item.validator = CardSecurityCodeValidator(publisher: item.$selectedCard)
        item.selectedCard = .americanExpress

        // When
        let shouldChange = sut.textField(
            sut.textField,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "12345"
        )
        sut.textField.text = "12345"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertTrue(shouldChange)
        XCTAssertEqual(item.value, "1234")
        XCTAssertTrue(item.isValid())
    }

    func test_entering_givenNonAmexAndMoreThanThreeDigits_shouldCapValueAndValidate() {
        // When
        sut.textField.text = "1234"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertEqual(item.value, "123")
        XCTAssertEqual(item.formattedValue, "123")
        XCTAssertTrue(item.isValid())
    }

    func test_entering_givenAmexAndMoreThanFourDigits_shouldCapValueAndValidate() {
        // Given
        item.formatter = CardSecurityCodeFormatter(publisher: item.$selectedCard)
        item.validator = CardSecurityCodeValidator(publisher: item.$selectedCard)
        item.selectedCard = .americanExpress

        // When
        sut.textField.text = "12345"
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertEqual(item.value, "1234")
        XCTAssertEqual(item.formattedValue, "1234")
        XCTAssertTrue(item.isValid())
    }

    func test_placeholder_givenNonAmex_shouldShowThreeDigits() {
        assert(for: .masterCard, showsDigits: 3)
    }

    func test_placeholder_givenAmex_shouldShowFourDigits() {
        assert(for: .americanExpress, showsDigits: 4)
    }

    func test_placeholder_givenNoSelectedCard_shouldShowThreeDigits() {
        XCTAssertEqual(
            item.placeholder,
            localizedString(.cardSecurityCodeHintThreeDigits, item.localizationParameters)
        )
    }

    func test_title_shouldUseCanonicalSecurityCodeLabel() {
        XCTAssertEqual(item.title, localizedString(.cardSecurityCodeLabel, item.localizationParameters))
    }

    func test_validationFailureMessage_givenEmptyCodeAndNonAmex_shouldUseThreeDigitsEmptyError() {
        // Setting a brand re-evaluates the message against the (empty) value.
        item.selectedCard = .masterCard
        XCTAssertFalse(item.isValid())
        XCTAssertEqual(
            item.validationFailureMessage,
            localizedString(.cardSecurityCodeErrorEmptyThreeDigits, item.localizationParameters)
        )
    }

    func test_validationFailureMessage_givenPartialCodeAndNonAmex_shouldUseThreeDigitsIncompleteError() {
        item.value = "1"
        XCTAssertFalse(item.isValid())
        XCTAssertEqual(
            item.validationFailureMessage,
            localizedString(.cardSecurityCodeErrorIncompleteThreeDigits, item.localizationParameters)
        )
    }

    func test_validationFailureMessage_givenEmptyCodeAndAmex_shouldUseFourDigitsEmptyError() {
        // Given
        item.validator = CardSecurityCodeValidator(publisher: item.$selectedCard)

        // When - selecting a brand re-evaluates the message against the (empty) value.
        item.selectedCard = .americanExpress

        // Then
        XCTAssertFalse(item.isValid())
        XCTAssertEqual(
            item.validationFailureMessage,
            localizedString(.cardSecurityCodeErrorEmptyFourDigits, item.localizationParameters)
        )
    }

    func test_validationFailureMessage_givenPartialCodeAndAmex_shouldUseFourDigitsIncompleteError() {
        // Given
        item.validator = CardSecurityCodeValidator(publisher: item.$selectedCard)
        item.selectedCard = .americanExpress

        // When
        item.value = "123"

        // Then
        XCTAssertFalse(item.isValid())
        XCTAssertEqual(
            item.validationFailureMessage,
            localizedString(.cardSecurityCodeErrorIncompleteFourDigits, item.localizationParameters)
        )
    }

    func test_validationFailureMessage_givenOptionalPartialCode_shouldUseThreeDigitsIncompleteError() {
        // Given
        item.displayMode = .optional

        // When
        item.value = "12"

        // Then
        XCTAssertFalse(item.isValid())
        XCTAssertEqual(
            item.validationFailureMessage,
            localizedString(.cardSecurityCodeErrorIncompleteThreeDigits, item.localizationParameters)
        )
    }

    func test_strings_givenCardBrands_shouldSelectMatchingHintsAndErrors() {
        let sut = CardSecurityCodeStrings.self
        let cases: [(CardBrand?, LocalizationKey, LocalizationKey, LocalizationKey)] = [
            (nil, .cardSecurityCodeHintThreeDigits, .cardSecurityCodeErrorEmptyThreeDigits, .cardSecurityCodeErrorIncompleteThreeDigits),
            (.visa, .cardSecurityCodeHintThreeDigits, .cardSecurityCodeErrorEmptyThreeDigits, .cardSecurityCodeErrorIncompleteThreeDigits),
            (.americanExpress, .cardSecurityCodeHintFourDigits, .cardSecurityCodeErrorEmptyFourDigits, .cardSecurityCodeErrorIncompleteFourDigits)
        ]
        for (brand, hint, empty, incomplete) in cases {
            XCTAssertEqual(sut.hint(for: brand, localizationParameters: nil), localizedString(hint, nil))
            XCTAssertEqual(
                sut.validationMessage(for: .securityCodeEmpty, brand: brand, localizationParameters: nil),
                localizedString(empty, nil)
            )
            XCTAssertEqual(
                sut.validationMessage(for: .securityCodePartial, brand: brand, localizationParameters: nil),
                localizedString(incomplete, nil)
            )
        }
    }

    func test_strings_givenNoCvcError_shouldReturnNil() {
        let sut = CardSecurityCodeStrings.self
        XCTAssertNil(sut.validationMessage(for: nil, brand: .visa, localizationParameters: nil))
        XCTAssertNil(sut.validationMessage(for: .cardNumberEmpty, brand: .visa, localizationParameters: nil))
    }

    func test_item_withoutView_shouldPrepareHintAndErrorForCurrentBrand() {
        let sut = makeItemSUT()
        XCTAssertEqual(sut.placeholder, localizedString(.cardSecurityCodeHintThreeDigits, nil))
        XCTAssertEqual(sut.validationFailureMessage, localizedString(.cardSecurityCodeErrorEmptyThreeDigits, nil))

        sut.selectedCard = .americanExpress
        XCTAssertEqual(sut.placeholder, localizedString(.cardSecurityCodeHintFourDigits, nil))
        XCTAssertEqual(sut.validationFailureMessage, localizedString(.cardSecurityCodeErrorEmptyFourDigits, nil))

        sut.selectedCard = nil
        XCTAssertEqual(sut.placeholder, localizedString(.cardSecurityCodeHintThreeDigits, nil))
    }

    func test_item_givenOptionalAndHiddenModes_shouldPreserveValidationPolicy() {
        let sut = makeItemSUT()
        sut.displayMode = .optional
        XCTAssertNil(sut.validationFailureMessage)
        sut.value = "12"
        XCTAssertEqual(sut.validationFailureMessage, localizedString(.cardSecurityCodeErrorIncompleteThreeDigits, nil))
        sut.value = "123"
        XCTAssertNil(sut.validationFailureMessage)
        sut.displayMode = .hidden
        XCTAssertNil(sut.validationFailureMessage)
    }

    func test_view_givenPreselectedAmex_shouldPreserveHintAndInitializeFrontIcon() {
        let item = makeItemSUT()
        item.selectedCard = .americanExpress
        let sut = FormCardSecurityCodeItemView(item: item)
        XCTAssertEqual(item.placeholder, localizedString(.cardSecurityCodeHintFourDigits, nil))
        XCTAssertTrue(sut.cardHintView.showFront)
        XCTAssertEqual(sut.textField.accessibilityLabel, "\(item.title ?? ""), \(item.placeholder ?? "")")
    }

    func test_view_givenHintAndTitleChanges_shouldUpdateAccessibilityWithoutGeneratingText() {
        let item = makeItemSUT()
        let sut = FormCardSecurityCodeItemView(item: item)
        item.placeholder = "Custom hint"
        item.title = "Custom title"
        XCTAssertEqual(sut.textField.accessibilityLabel, "Custom title, Custom hint")
        sut.showValidation()
        let errorLabel = sut.textField.accessibilityLabel
        item.placeholder = "Another hint"
        XCTAssertEqual(sut.textField.accessibilityLabel, errorLabel)
    }

    func test_strings_givenLocalizationProvider_shouldUseOverridesAndFallbackForMissingKeys() {
        let sut = CardSecurityCodeStrings.self
        let parameters = LocalizationParameters(enforcedLocale: "en-US").withProvider(StringsProvider(values: [
            .cardSecurityCodeHint3Digits: "Custom hint",
            CheckoutLocalizationKey(localizationKey: .cardSecurityCodeErrorEmptyThreeDigits): "Custom error"
        ]))
        XCTAssertEqual(sut.hint(for: .visa, localizationParameters: parameters), "Custom hint")
        XCTAssertEqual(
            sut.validationMessage(for: .securityCodeEmpty, brand: .visa, localizationParameters: parameters),
            "Custom error"
        )
        XCTAssertEqual(
            sut.validationMessage(for: .securityCodePartial, brand: .visa, localizationParameters: parameters),
            localizedString(.cardSecurityCodeErrorIncompleteThreeDigits, LocalizationParameters(enforcedLocale: "en-US"))
        )
    }

    private struct StringsProvider: CheckoutLocalizationProvider {
        let values: [CheckoutLocalizationKey: String]

        func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
            values[key]
        }
    }

    private func makeItemSUT() -> FormCardSecurityCodeItem {
        FormCardSecurityCodeItem()
    }

    private func assert(
        for brand: CardBrand,
        showsDigits digits: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let hintKey: LocalizationKey = digits == 4
            ? .cardSecurityCodeHintFourDigits
            : .cardSecurityCodeHintThreeDigits
        let expectedPlaceholder = localizedString(hintKey, item.localizationParameters)
        item.selectedCard = brand
        XCTAssertEqual(item.placeholder, expectedPlaceholder, file: file, line: line)
    }
}
