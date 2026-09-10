//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import Testing

struct AmountAwarePaymentStringsPolicyTests {

    /// Every `PaymentStyle` case. Used to prove behaviour across the full enum.
    private static let allPaymentStyles: [PaymentStyle] = [
        .immediate,
        .needsRedirectToThirdParty("PayPal")
    ]

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
        let title = sut.payButtonTitle(with: amount, style: .immediate, localizationParameters: localizationParameters)

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
        let title = sut.payButtonTitle(with: amount, style: .immediate, localizationParameters: bundle)

        // Then
        #expect(title == expectedTitle)
    }

    // MARK: - Missing amount (payment style must be ignored)

    @Test(arguments: allPaymentStyles)
    func nilAmount_forAnyStyle_when_resolvingTitle_then_returnsDefaultSubmitTitle(style: PaymentStyle) {
        // Given
        let sut = makeSUT()

        // When
        let title = sut.payButtonTitle(with: nil, style: style, localizationParameters: nil)

        // Then - the style is irrelevant when there is no amount
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
        let title = sut.payButtonTitle(with: amount, style: .immediate, localizationParameters: localizationParameters)

        // Then
        #expect(title == scenario.expectedTitle)
    }

    @Test(arguments: allPaymentStyles)
    func nonZeroAmount_forAnyStyle_when_resolvingTitle_then_returnsFormattedSubmitTitle(style: PaymentStyle) {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 1000, currencyCode: "EUR", localeIdentifier: "en_US")

        // When
        let title = sut.payButtonTitle(with: amount, style: style, localizationParameters: nil)

        // Then - the style is irrelevant for a positive amount
        #expect(title == "Pay €10.00")
    }

    // MARK: - Zero amount (payment style selects the preauthorization copy)

    /// One zero-amount case. For a zero amount the amount value is never rendered; instead the
    /// `PaymentStyle` and the bundle locale select the preauthorization copy. `amountLocaleIdentifier`
    /// exists only to prove the amount's own locale never leaks into that copy.
    struct ZeroAmountScenario {
        let style: PaymentStyle
        let amountLocaleIdentifier: String?
        let bundleLocale: String?
        let expectedTitle: String
    }

    @Test(arguments: [
        // Default locale, immediate confirmation.
        ZeroAmountScenario(style: .immediate, amountLocaleIdentifier: nil, bundleLocale: nil, expectedTitle: "Confirm preauthorization"),
        // Default locale, redirect to a third party interpolates the provider name.
        ZeroAmountScenario(style: .needsRedirectToThirdParty("test_name"), amountLocaleIdentifier: nil, bundleLocale: nil, expectedTitle: "Preauthorize with test_name"),
        // Enforced locale, immediate confirmation is localized.
        ZeroAmountScenario(style: .immediate, amountLocaleIdentifier: nil, bundleLocale: "is-IS", expectedTitle: "Staðfesta greiðsluheimild"),
        // Enforced locale, redirect title is localized and interpolates the provider name.
        ZeroAmountScenario(style: .needsRedirectToThirdParty("Klarna"), amountLocaleIdentifier: nil, bundleLocale: "is-IS", expectedTitle: "Heimila greiðslu með Klarna"),
        // The amount's own locale must not leak into the zero-amount (preauthorization) title.
        ZeroAmountScenario(style: .immediate, amountLocaleIdentifier: "fr-FR", bundleLocale: nil, expectedTitle: "Confirm preauthorization")
    ])
    func zeroAmount_forScenario_when_resolvingTitle_then_returnsPreauthorizationTitle(_ scenario: ZeroAmountScenario) {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 0, currencyCode: "EUR", localeIdentifier: scenario.amountLocaleIdentifier)
        let localizationParameters = scenario.bundleLocale.map { LocalizationParameters(enforcedLocale: $0) }

        // When
        let title = sut.payButtonTitle(with: amount, style: scenario.style, localizationParameters: localizationParameters)

        // Then
        #expect(title == scenario.expectedTitle)
    }

    private func makeSUT() -> AmountAwarePaymentStringsPolicy.Type {
        AmountAwarePaymentStringsPolicy.self
    }
}
