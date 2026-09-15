//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import Testing

struct AmountAwarePaymentStringsPolicyTests {

    // MARK: - Supported locales

    /// The pay button title with an amount for every localization bundle shipped with the SDK.
    /// It also demonstrates that the amount's own locale takes precedence over the bundle locale
    /// for the number: e.g. `fr-FR` renders `"Payer €10.00"`, not `"Payer 10,00 €"`.
    @Test(arguments: [
        ("ar", "دفع €10.00"),
        ("bg-BG", "Платете €10.00"),
        ("ca-ES", "Pagueu €10.00"),
        ("cs-CZ", "Zaplatit €10.00"),
        ("da-DK", "Betal €10.00"),
        ("de-DE", "€10.00 zahlen"),
        ("el-GR", "Πληρωμή €10.00"),
        ("en-US", "Pay €10.00"),
        ("es-ES", "Pagar €10.00"),
        ("et-EE", "Maksa €10.00"),
        ("fi", "Maksa €10.00"),
        ("fr-FR", "Payer €10.00"),
        ("hr-HR", "Platiti €10.00"),
        ("hu-HU", "Fizetendő: €10.00"),
        ("is-IS", "Greiða €10.00"),
        ("it-IT", "Paga €10.00"),
        ("ja-JP", "€10.00のお支払い"),
        ("ko", "€10.00 결제"),
        ("lt-LT", "Mokėti €10.00"),
        ("lv-LV", "Maksāt €10.00"),
        ("nb-NO", "Betal €10.00"),
        ("nl-NL", "€10.00 betalen"),
        ("pl-PL", "Zapłać €10.00"),
        ("pt-BR", "Pagar €10.00"),
        ("pt-PT", "Pagar €10.00"),
        ("ro-RO", "Plătiți €10.00"),
        ("ru-RU", "Заплатить €10.00"),
        ("sk-SK", "Zaplatiť €10.00"),
        ("sl-SI", "Plačilo €10.00"),
        ("sv-SE", "Betala €10.00"),
        ("zh-CN", "支付 €10.00"),
        ("zh-TW", "支付 €10.00")
    ])
    func payButtonTitle_forEachSupportedLocaleWithAmount_then_returnsLocalizedFormattedTitle(
        localeIdentifier: String,
        expectedTitle: String
    ) {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 1000, currencyCode: "EUR", localeIdentifier: "en_US")
        let localizationParameters = LocalizationParameters(enforcedLocale: localeIdentifier)

        // When
        let title = sut.payButtonTitle(with: amount, localizationParameters: localizationParameters)

        // Then
        #expect(title == expectedTitle)
    }

    // MARK: - Locale-specific number formatting

    /// The rendered pay button title for the same €1,234.56 amount across every supported locale,
    /// Only the amount's own locale drives the number rendering
    @Test(arguments: [
        ("ar", "Pay \u{200F}1,234.56\u{00A0}€"), // Pay 1,234.56 € (leading RTL mark)
        ("bg-BG", "Pay 1234,56\u{00A0}€"), // Pay 1234,56 €
        ("ca-ES", "Pay 1.234,56\u{00A0}€"), // Pay 1.234,56 €
        ("cs-CZ", "Pay 1\u{00A0}234,56\u{00A0}€"), // Pay 1 234,56 €
        ("da-DK", "Pay 1.234,56\u{00A0}€"), // Pay 1.234,56 €
        ("de-DE", "Pay 1.234,56\u{00A0}€"), // Pay 1.234,56 €
        ("el-GR", "Pay 1.234,56\u{00A0}€"), // Pay 1.234,56 €
        ("en-US", "Pay €1,234.56"), // Pay €1,234.56
        ("es-ES", "Pay 1234,56\u{00A0}€"), // Pay 1234,56 €
        ("et-EE", "Pay 1234,56\u{00A0}€"), // Pay 1234,56 €
        ("fi", "Pay 1\u{00A0}234,56\u{00A0}€"), // Pay 1 234,56 €
        ("fr-FR", "Pay 1\u{202F}234,56\u{00A0}€"), // Pay 1 234,56 € (narrow no-break group separator)
        ("hr-HR", "Pay 1.234,56\u{00A0}€"), // Pay 1.234,56 €
        ("hu-HU", "Pay 1234,56\u{00A0}EUR"), // Pay 1234,56 EUR
        ("is-IS", "Pay 1.234,56\u{00A0}EUR"), // Pay 1.234,56 EUR
        ("it-IT", "Pay 1234,56\u{00A0}€"), // Pay 1234,56 €
        ("ja-JP", "Pay €1,234.56"), // Pay €1,234.56
        ("ko", "Pay €1,234.56"), // Pay €1,234.56
        ("lt-LT", "Pay 1\u{00A0}234,56\u{00A0}€"), // Pay 1 234,56 €
        ("lv-LV", "Pay 1234,56\u{00A0}€"), // Pay 1234,56 €
        ("nb-NO", "Pay 1\u{00A0}234,56\u{00A0}€"), // Pay 1 234,56 €
        ("nl-NL", "Pay €\u{00A0}1.234,56"), // Pay € 1.234,56
        ("pl-PL", "Pay 1234,56\u{00A0}€"), // Pay 1234,56 €
        ("pt-BR", "Pay €\u{00A0}1.234,56"), // Pay € 1.234,56
        ("pt-PT", "Pay 1234,56\u{00A0}€"), // Pay 1234,56 €
        ("ro-RO", "Pay 1.234,56\u{00A0}EUR"), // Pay 1.234,56 EUR
        ("ru-RU", "Pay 1\u{00A0}234,56\u{00A0}€"), // Pay 1 234,56 €
        ("sk-SK", "Pay 1\u{00A0}234,56\u{00A0}€"), // Pay 1 234,56 €
        ("sl-SI", "Pay 1234,56\u{00A0}€"), // Pay 1234,56 €
        ("sv-SE", "Pay 1\u{00A0}234,56\u{00A0}€"), // Pay 1 234,56 €
        ("zh-CN", "Pay €1,234.56"), // Pay €1,234.56
        ("zh-TW", "Pay €1,234.56") // Pay €1,234.56
    ])
    func payButtonTitle_forEachAmountLocaleWithConstantBundle_then_formatsNumberForThatLocale(
        amountLocaleIdentifier: String,
        expectedTitle: String
    ) {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 123456, currencyCode: "EUR", localeIdentifier: amountLocaleIdentifier)
        let bundle = LocalizationParameters(enforcedLocale: "en-US")

        // When
        let title = sut.payButtonTitle(with: amount, localizationParameters: bundle)

        // Then
        #expect(title == expectedTitle)
    }

    // MARK: - Missing amount

    @Test
    func nilAmount_when_resolvingTitle_then_returnsDefaultSubmitTitle() {
        // Given
        let sut = makeSUT()

        // When
        let title = sut.payButtonTitle(with: nil, localizationParameters: nil)

        // Then
        #expect(title == "Pay")
    }

    // MARK: - Non-zero amount formatting rules

    /// This isolates the non-zero formatting
    struct NonZeroAmountScenario {
        let minorUnits: Int
        let currencyCode: String
        let amountLocaleIdentifier: String?
        let bundleLocale: String?
        let expectedTitle: String
    }

    @Test(arguments: [
        // Missing amount locale: the number falls back to the bundle locale (here fr-FR).
        NonZeroAmountScenario(minorUnits: 1000, currencyCode: "EUR", amountLocaleIdentifier: nil, bundleLocale: "fr-FR", expectedTitle: "Payer 10,00\u{00A0}€"), // Payer 10,00 €
        // Negative amounts are still formatted, never the zero-amount preauthorization title.
        NonZeroAmountScenario(minorUnits: -1000, currencyCode: "EUR", amountLocaleIdentifier: "en_US", bundleLocale: nil, expectedTitle: "Pay -€10.00"),
        // Zero-decimal currency renders without minor units.
        NonZeroAmountScenario(minorUnits: 1000, currencyCode: "JPY", amountLocaleIdentifier: "en_US", bundleLocale: nil, expectedTitle: "Pay ¥1,000")
    ])
    func nonZeroAmount_forScenario_when_resolvingTitle_then_returnsFormattedSubmitTitle(_ scenario: NonZeroAmountScenario) {
        // Given
        let sut = makeSUT()
        let amount = Amount(
            value: scenario.minorUnits,
            currencyCode: scenario.currencyCode,
            localeIdentifier: scenario.amountLocaleIdentifier
        )
        let localizationParameters = scenario.bundleLocale.map { LocalizationParameters(enforcedLocale: $0) }

        // When
        let title = sut.payButtonTitle(with: amount, localizationParameters: localizationParameters)

        // Then
        #expect(title == scenario.expectedTitle)
    }

    // MARK: - Zero amount

    struct ZeroAmountScenario {
        let amountLocaleIdentifier: String?
        let bundleLocale: String?
        let expectedTitle: String
    }

    @Test(arguments: [
        ZeroAmountScenario(amountLocaleIdentifier: nil, bundleLocale: nil, expectedTitle: "Save details"),
        // TODO: Robert: I expect the below test to fail once we have localizations in place.
        ZeroAmountScenario(amountLocaleIdentifier: nil, bundleLocale: "is-IS", expectedTitle: "Save details"),
        ZeroAmountScenario(amountLocaleIdentifier: "fr-FR", bundleLocale: nil, expectedTitle: "Save details")
    ])
    func zeroAmount_forScenario_when_resolvingTitle_then_returnsSaveDetails(_ scenario: ZeroAmountScenario) {
        // Given
        let sut = makeSUT()
        let amount = Amount(
            value: 0,
            currencyCode: "EUR",
            localeIdentifier: scenario.amountLocaleIdentifier
        )
        let localizationParameters = scenario.bundleLocale.map { LocalizationParameters(enforcedLocale: $0) }

        // When
        let title = sut.payButtonTitle(with: amount, localizationParameters: localizationParameters)

        // Then
        #expect(title == scenario.expectedTitle)
    }

    // MARK: - Payment method list strings

    @Test
    func paymentMethodListStrings_withNilAmount_then_showsPaymentOptionsAndCompletePaymentDescription() {
        // Given
        let sut = makeSUT()

        // When
        let headerTitle = sut.paymentMethodListHeaderTitle(with: nil, localizationParameters: nil)
        let subtitle = sut.paymentMethodListSubtitle(with: nil, localizationParameters: nil)

        // Then
        #expect(headerTitle == "Payment options")
        #expect(subtitle == "Select your preferred payment option and complete the payment")
    }

    @Test
    func paymentMethodListStrings_withZeroAmount_then_showsSaveDetails() {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 0, currencyCode: "EUR", localeIdentifier: nil)

        // When
        let headerTitle = sut.paymentMethodListHeaderTitle(with: amount, localizationParameters: nil)
        let subtitle = sut.paymentMethodListSubtitle(with: amount, localizationParameters: nil)

        // Then
        #expect(headerTitle == "Save details")
        #expect(subtitle == "Select your preferred payment option and save your details for future transactions")
    }

    @Test
    func paymentMethodListStrings_withPositiveAmount_then_showsFormattedAmountAndCompletePaymentDescription() {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 1000, currencyCode: "EUR", localeIdentifier: "en_US")

        // When
        let headerTitle = sut.paymentMethodListHeaderTitle(with: amount, localizationParameters: nil)
        let subtitle = sut.paymentMethodListSubtitle(with: amount, localizationParameters: nil)

        // Then
        #expect(headerTitle == "€10.00")
        #expect(subtitle == "Select your preferred payment option and complete the payment")
    }

    private func makeSUT() -> AmountAwarePaymentStringsPolicy.Type {
        AmountAwarePaymentStringsPolicy.self
    }
}
