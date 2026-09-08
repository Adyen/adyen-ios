//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import Testing

struct SubmitButtonTitlePolicyTests {

    // MARK: - Missing amount

    @Test
    func nilAmount_when_resolvingTitle_then_returnsDefaultSubmitTitle() {
        // Given
        let sut = makeSUT()

        // When
        let title = sut.title(with: nil, style: .immediate, nil)

        // Then
        #expect(title == "Pay")
    }

    @Test
    func nilAmount_withEnforcedLocale_when_resolvingTitle_then_returnsLocalizedSubmitTitle() {
        // Given
        let sut = makeSUT()
        let localizationParameters = LocalizationParameters(enforcedLocale: "is-IS")

        // When
        let title = sut.title(with: nil, style: .immediate, localizationParameters)

        // Then
        #expect(title == "Greiða")
    }

    // MARK: - Non-zero amount

    @Test
    func nonZeroAmount_when_resolvingTitle_then_returnsFormattedSubmitTitle() {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 1000, currencyCode: "EUR", localeIdentifier: "en_US")

        // When
        let title = sut.title(with: amount, style: .immediate, nil)

        // Then
        #expect(title == "Pay €10.00")
    }

    @Test
    func amountWithoutLocale_when_resolvingTitle_then_usesLocalizationParametersLocale() {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 1000, currencyCode: "EUR")
        let localizationParameters = LocalizationParameters(enforcedLocale: "fr-FR")

        // When
        let title = sut.title(with: amount, style: .immediate, localizationParameters)

        // Then
        #expect(title == "Payer 10,00 €")
    }

    @Test
    func amountWithExplicitLocale_when_resolvingTitle_then_prefersAmountLocaleOverParameters() {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 1000, currencyCode: "EUR", localeIdentifier: "en_US")
        let localizationParameters = LocalizationParameters(enforcedLocale: "fr-FR")

        // When
        let title = sut.title(with: amount, style: .immediate, localizationParameters)

        // Then
        #expect(title == "Payer €10.00")
    }

    // MARK: - Zero amount

    @Test(arguments: [
        (PaymentStyle.immediate, "Confirm preauthorization"),
        (PaymentStyle.needsRedirectToThirdParty("test_name"), "Preauthorize with test_name")
    ])
    func zeroAmount_when_resolvingTitle_then_returnsTitleForPaymentStyle(style: PaymentStyle, expectedTitle: String) {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 0, currencyCode: "EUR")

        // When
        let title = sut.title(with: amount, style: style, nil)

        // Then
        #expect(title == expectedTitle)
    }

    @Test
    func zeroAmount_withEnforcedLocale_when_resolvingTitle_then_returnsLocalizedPreauthorizationTitle() {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 0, currencyCode: "EUR")
        let localizationParameters = LocalizationParameters(enforcedLocale: "is-IS")

        // When
        let title = sut.title(with: amount, style: .immediate, localizationParameters)

        // Then
        #expect(title == "Staðfesta greiðsluheimild")
    }

    @Test
    func zeroAmount_withEnforcedLocaleAndProviderName_when_resolvingTitle_then_returnsLocalizedProviderTitle() {
        // Given
        let sut = makeSUT()
        let amount = Amount(value: 0, currencyCode: "EUR")
        let localizationParameters = LocalizationParameters(enforcedLocale: "is-IS")

        // When
        let title = sut.title(
            with: amount,
            style: .needsRedirectToThirdParty("PayPal"),
            localizationParameters
        )

        // Then
        #expect(title == "Heimila greiðslu með PayPal")
    }

    private func makeSUT() -> SubmitButtonTitlePolicy.Type {
        SubmitButtonTitlePolicy.self
    }
}
