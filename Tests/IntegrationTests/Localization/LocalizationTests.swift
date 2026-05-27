//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class LocalizationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        resetLocalizationTestState()
    }

    private func resetLocalizationTestState() {
        LocalizationWarningLog.reset()
    }

    func testResolvedLocalizedStringIfAvailableIgnoresDebugPlaceholder() {
        XCTAssertNil(resolvedLocalizedStringIfAvailable("adyen.submitButton.formatted", forKey: "adyen.submitButton.formatted"))
        XCTAssertNil(resolvedLocalizedStringIfAvailable("ADYEN.SUBMITBUTTON.FORMATTED", forKey: "adyen.submitButton.formatted"))
        XCTAssertEqual(
            resolvedLocalizedStringIfAvailable("Confirm %@ payment", forKey: "adyen.submitButton.formatted"),
            "Confirm %@ payment"
        )
    }

    // MARK: - Enforced translation

    func testEnforcedLocalization() {
        var parameters = LocalizationParameters(enforcedLocale: "it-IT")
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Conferma il pagamento di test")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Verifica la Carta")

        XCTAssertNil(parameters.bundle)
        XCTAssertNil(parameters.keySeparator)
        XCTAssertNil(parameters.tableName)
        XCTAssertEqual(parameters.locale, "it-IT")

        parameters = LocalizationParameters(enforcedLocale: "ar")
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "تأكيد الدفع باستخدام test")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "التحقق من بطاقتك")
        XCTAssertEqual(parameters.locale, "ar")

        parameters = LocalizationParameters(enforcedLocale: "is-IS")
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Staðfesta test greiðslu")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Staðfestu kortið þitt")
        XCTAssertEqual(localizedString(.submitButton, parameters), "Greiða")
        XCTAssertEqual(parameters.locale, "is-IS")
    }

    func testEnforcedLocalizationOverrides() {
        let parameters = LocalizationParameters(
            enforcedLocale: "is-IS",
            bundle: Bundle(for: LocalizationTests.self)
        )
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "TestBundle - Confirm test payment - IS")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "TestBundle - Verify your card - IS")

        // Fallback to SDK's translation for known locale
        XCTAssertEqual(localizedString(.submitButton, parameters), "Greiða")

        XCTAssertNotNil(parameters.bundle)
        XCTAssertNil(parameters.keySeparator)
        XCTAssertEqual(parameters.locale, "is-IS")
    }

    func testEnforcedLocalizationOverridesWithCustomSeparator() {
        let parameters = LocalizationParameters(
            enforcedLocale: "ro-RO",
            bundle: Bundle(for: LocalizationTests.self),
            tableName: "EnforceLocaleTests",
            keySeparator: "-"
        )
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "TestBundle - Confirm test payment - RO")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "TestBundle - Verify your card - RO")

        // Fallback to SDK's translation for known locale, ignoring custom separator
        XCTAssertEqual(localizedString(.submitButton, parameters), "Plătiți")

        XCTAssertNotNil(parameters.bundle)
        XCTAssertEqual(parameters.keySeparator, "-")
        XCTAssertEqual(parameters.tableName, "EnforceLocaleTests")
        XCTAssertEqual(parameters.locale, "ro-RO")
    }

    func testEnforcedLocalizationOverridesUnsupportedLocale() {
        let parameters = LocalizationParameters(
            enforcedLocale: "hi",
            bundle: Bundle(for: LocalizationTests.self)
        )

        // This string exist on Custom bundle, but SDK will first check on Main bundle
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Confirm test payment - HI")

        // Will not find a line on Main bundle and fallback to Custom bundle
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "TestBundle - Verify your card - HI")

        // Ultimate fallback to English
        XCTAssertEqual(localizedString(.submitButton, parameters), "Pay")
    }

    func test_localizedString_withNilParameters_shouldReturnSDKDefault() {
        XCTAssertEqual(localizedString(.cardStoredTitle, nil), "Verify your card")
    }

    func test_localizedString_withFormattedKeyAndArguments_shouldFormatString() {
        XCTAssertEqual(localizedString(.dropInStoredTitle, nil, "test"), "Confirm test payment")
    }

    func test_localizedString_withFormattedKeyAndMissingTranslation_shouldFallbackToEnglish() {
        let parameters = LocalizationParameters(
            bundle: Bundle(for: LocalizationTests.self),
            tableName: "EnforceLocaleTests",
            keySeparator: "-"
        )

        XCTAssertEqual(localizedString(.submitButtonFormatted, parameters, "€1.00"), "Pay €1.00")
    }

    func test_localizedString_withUnsupportedEnforcedLocaleAndPartialCustomCoverage_shouldMixCustomAndEnglishFallback() {
        let parameters = LocalizationParameters(
            enforcedLocale: "hi",
            bundle: Bundle(for: LocalizationTests.self)
        )

        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "TestBundle - Verify your card - HI")
        XCTAssertEqual(localizedString(.submitButton, parameters), "Pay")
    }

    // MARK: - Button title

    func testLocalizationWitZeroPayment() {
        XCTAssertEqual(localizedSubmitButtonTitle(with: Amount(value: 0, currencyCode: "EUR"), style: .needsRedirectToThirdParty("test_name"), nil), "Preauthorize with test_name")

        XCTAssertEqual(localizedSubmitButtonTitle(with: Amount(value: 0, currencyCode: "EUR"), style: .immediate, nil), "Confirm preauthorization")
    }
    
    // MARK: - Custom Recognized TableName
    
    /// Default Separator
    func testLocalizationWithCustomRecognizedTableNameAndDefaultSeparator() {
        let parameters = LocalizationParameters(tableName: "AdyenUIHost")
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Test-Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Test-Verify your card")

        XCTAssertNil(parameters.bundle)
        XCTAssertNil(parameters.keySeparator)
        XCTAssertEqual(parameters.tableName, "AdyenUIHost")
        XCTAssertNil(parameters.locale)
    }

    /// Unrecognized Separator
    func testLocalizationWithCustomRecognizedTableNameAndCustomUnrecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: "*")
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Test-Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Test-Verify your card")

        XCTAssertNil(parameters.bundle)
        XCTAssertEqual(parameters.keySeparator, "*")
        XCTAssertEqual(parameters.tableName, "AdyenUIHost")
        XCTAssertNil(parameters.locale)
    }

    /// Recognized Separator
    func testLocalizationWithCustomRecognizedTableNameAndCustomRecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Test-Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Test-Verify your card")
    }

    // MARK: - Custom Bundle

    func testLocalizationWithCustomRecognizedTableNameAndDefaultSeparatorAndCustomBundle() {
        let parameters = LocalizationParameters(
            bundle: Bundle(for: LocalizationTests.self),
            tableName: "AdyenTests"
        )
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "TestBundle-Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "TestBundle-Verify your card")

        XCTAssertEqual(parameters.bundle, Bundle(for: LocalizationTests.self))
        XCTAssertNil(parameters.keySeparator)
        XCTAssertEqual(parameters.tableName, "AdyenTests")
        XCTAssertNil(parameters.locale)
    }

    func testLocalizationWithCustomBundleFallbackToMainBundle() {
        let parameters = LocalizationParameters(
            bundle: Bundle(for: LocalizationTests.self),
            tableName: nil,
            keySeparator: nil
        )
        XCTAssertEqual(localizedString(LocalizationKey(key: "any.key.1"), parameters, "test"), "value 1 test")
        XCTAssertEqual(localizedString(LocalizationKey(key: "any.key.2"), parameters), "value 2")
    }

    func testLocalizationWithCustomBundleFallbackToSDKBundle() {
        let parameters = LocalizationParameters(
            bundle: Bundle(for: LocalizationTests.self),
            tableName: nil,
            keySeparator: nil
        )
        XCTAssertEqual(localizedString(.blikPlaceholder, parameters), "123–456")
    }

    func testLocalizationWithCustomRecognizedTableNameAndCustomRecognizedSeparatorAndCustomBundle() {
        let parameters = LocalizationParameters(
            bundle: Bundle(for: LocalizationTests.self),
            tableName: "AdyenTestsCustomSeparator",
            keySeparator: "_"
        )
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "TestBundle-Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "TestBundle-Verify your card")
    }
    
    // MARK: - Custom Unrecognized TableName
    
    /// Default Separator
    func testLocalizationWithCustomUnrecognizedTableNameAndDefaultSeparator() {
        let parameters = LocalizationParameters(tableName: "123", keySeparator: nil)
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Verify your card")
    }
    
    /// Unrecognized Separator
    func testLocalizationWithCustomUnrecognizedTableNameAndCustomUnrecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: "123", keySeparator: "*")
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Verify your card")
    }
    
    /// Recognized Separator
    func testLocalizationWithCustomUnrecognizedTableNameAndCustomRecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: "123", keySeparator: "_")
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Verify your card")
    }
    
    // MARK: - SDK bundle default TableName
    
    /// Default Separator
    func testLocalizationWithDefaultTableNameAndDefaultSeparator() {
        let parameters = LocalizationParameters(tableName: nil, keySeparator: nil)
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Verify your card")
    }
    
    /// Unrecognized Separator
    func testLocalizationWithDefaultTableNameAndCustomUnrecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: nil, keySeparator: "*")
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Verify your card")
    }
    
    /// Recognized Separator
    func testLocalizationWithDefaultTableNameAndCustomRecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: nil, keySeparator: "_")
        XCTAssertEqual(localizedString(.dropInStoredTitle, parameters, "test"), "Confirm test payment")
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Verify your card")
    }
    
    // MARK: - App bundle default TableName
    
    /// Default Separator
    func testLocalizationWithDefaultAppBundleTableNameAndDefaultSeparator() {
        let parameters = LocalizationParameters(tableName: nil, keySeparator: nil)
        XCTAssertEqual(localizedString(LocalizationKey(key: "any.key.1"), parameters, "test"), "value 1 test")
        XCTAssertEqual(localizedString(LocalizationKey(key: "any.key.2"), parameters), "value 2")
    }
    
    /// Unrecognized Separator
    func testLocalizationWithDefaultAppBundleTableNameAndUnrecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: nil, keySeparator: "*")
        XCTAssertEqual(localizedString(LocalizationKey(key: "any.key.1"), parameters, "test"), "value 1 test")
        XCTAssertEqual(localizedString(LocalizationKey(key: "any.key.2"), parameters), "value 2")
    }

    // MARK: - New language support via merchant app bundle

    /// Validates the recommended path for adding a language the SDK does not ship:
    /// merchants place `.strings` or `.xcstrings` with `adyen.*` keys in their app bundle
    /// and the SDK resolves them automatically — no `CheckoutLocalizationProvider` is required.
    func test_newLanguageSupport_usingMerchantBundle_shouldResolveFromBundleWithoutProvider() {
        // Simulates a merchant app bundle that provides Hindi translations.
        // Hindi is not shipped by the SDK, so it represents any newly added language.
        let parameters = LocalizationParameters(
            enforcedLocale: "hi",
            bundle: Bundle(for: LocalizationTests.self)
        )

        // Keys present in the merchant bundle resolve to the merchant's translations.
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "TestBundle - Verify your card - HI")

        // Keys absent from the merchant bundle fall back to the SDK's English strings.
        XCTAssertEqual(localizedString(.submitButton, parameters), "Pay")
    }

    // MARK: - Provider-first resolution

    func test_localizedString_withProvider_shouldReturnProviderValue() {
        let provider = MockCheckoutLocalizationProvider(values: [.cardNumber: "Custom card number"])
        let parameters = LocalizationParameters().withProvider(provider)

        XCTAssertEqual(localizedString(.cardNumberItemTitle, parameters), "Custom card number")
    }

    func test_localizedString_withProviderReturningNil_shouldFallbackToBundleChain() {
        let provider = MockCheckoutLocalizationProvider(values: [:])
        let parameters = LocalizationParameters(enforcedLocale: "it-IT").withProvider(provider)

        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Verifica la Carta")
    }

    func test_localizedString_withProviderReturningEmptyString_shouldFallbackToBundleChain() {
        let provider = MockCheckoutLocalizationProvider(values: [.cardNumber: ""])
        let parameters = LocalizationParameters(enforcedLocale: "it-IT").withProvider(provider)

        XCTAssertEqual(localizedString(.cardNumberItemTitle, parameters), "Numero carta")
    }

    func test_localizedString_withProviderAndArguments_shouldFormatProviderValue() {
        let provider = MockCheckoutLocalizationProvider(values: [.generalCancel: "Cancelled %@"])
        let parameters = LocalizationParameters().withProvider(provider)

        XCTAssertEqual(localizedString(.cancelButton, parameters, "now"), "Cancelled now")
    }

    func test_localizedString_withProviderReturningNilForUnknownKey_shouldFallbackToBundle() {
        let provider = MockCheckoutLocalizationProvider(values: [:])
        let parameters = LocalizationParameters().withProvider(provider)

        // `.cardStoredTitle` has no public `CheckoutLocalizationKey` counterpart. The provider
        // is still consulted, returns nil for the unrecognized key, and the bundle fallback wins.
        XCTAssertEqual(localizedString(.cardStoredTitle, parameters), "Verify your card")
    }

    func test_localizedString_withProvider_shouldPassResolvedLocale() {
        let provider = MockCheckoutLocalizationProvider(values: [.cardNumber: "Custom"])
        let parameters = LocalizationParameters(enforcedLocale: "fr-FR").withProvider(provider)

        _ = localizedString(.cardNumberItemTitle, parameters)

        XCTAssertEqual(provider.lastLocale?.identifier, "fr-FR")
    }

    func test_localizedString_withProviderMissingUnsupportedLocaleAndKnownKey_shouldWarnAndFallback() {
        let provider = MockCheckoutLocalizationProvider(values: [:])
        let parameters = LocalizationParameters(enforcedLocale: "zu").withProvider(provider)
        let expected = localizedString(.cardNumberItemTitle, LocalizationParameters(enforcedLocale: "en-US"))

        let warnings = recordWarnings {
            XCTAssertEqual(localizedString(.cardNumberItemTitle, parameters), expected)
        }

        XCTAssertEqual(
            warnings,
            [LocalizationWarning(localeIdentifier: "zu", key: LocalizationKey.cardNumberItemTitle.key, source: .provider)]
        )
    }

    func test_localizedString_withProviderMissingUnsupportedLocaleAndUnknownKey_shouldWarnAndFallback() {
        let provider = MockCheckoutLocalizationProvider(values: [:])
        let parameters = LocalizationParameters(enforcedLocale: "zu").withProvider(provider)
        let expected = localizedString(.cardStoredTitle, LocalizationParameters(enforcedLocale: "en-US"))

        let warnings = recordWarnings {
            XCTAssertEqual(localizedString(.cardStoredTitle, parameters), expected)
        }

        XCTAssertEqual(
            warnings,
            [LocalizationWarning(localeIdentifier: "zu", key: LocalizationKey.cardStoredTitle.key, source: .provider)]
        )
    }

    func test_localizedString_withProviderMissingSupportedLocale_shouldFallbackWithoutWarning() {
        let provider = MockCheckoutLocalizationProvider(values: [:])
        let parameters = LocalizationParameters(enforcedLocale: "it-IT").withProvider(provider)
        let expected = localizedString(.cardNumberItemTitle, LocalizationParameters(enforcedLocale: "it-IT"))

        let warnings = recordWarnings {
            XCTAssertEqual(localizedString(.cardNumberItemTitle, parameters), expected)
        }

        XCTAssertTrue(warnings.isEmpty)
    }

    func test_localizedString_withRepeatedProviderMiss_shouldWarnOnlyOnce() {
        let provider = MockCheckoutLocalizationProvider(values: [:])
        let parameters = LocalizationParameters(enforcedLocale: "zu").withProvider(provider)

        let warnings = recordWarnings {
            _ = localizedString(.cardNumberItemTitle, parameters)
            _ = localizedString(.cardNumberItemTitle, parameters)
        }

        XCTAssertEqual(
            warnings,
            [LocalizationWarning(localeIdentifier: "zu", key: LocalizationKey.cardNumberItemTitle.key, source: .provider)]
        )
    }

    func test_localizedString_withUnsupportedLocaleAndPartialMerchantBundleCoverage_shouldWarnAndFallback() {
        let parameters = LocalizationParameters(enforcedLocale: "hi", bundle: Bundle(for: LocalizationTests.self))
        let expected = localizedString(.submitButton, LocalizationParameters(enforcedLocale: "en-US"))

        let warnings = recordWarnings {
            XCTAssertEqual(localizedString(.submitButton, parameters), expected)
        }

        XCTAssertEqual(
            warnings,
            [LocalizationWarning(localeIdentifier: "hi", key: LocalizationKey.submitButton.key, source: .bundle)]
        )
    }

    func test_localizedString_withSupportedLocaleAndPartialMerchantBundleCoverage_shouldFallbackWithoutWarning() {
        let parameters = LocalizationParameters(enforcedLocale: "is-IS", bundle: Bundle(for: LocalizationTests.self))
        let expected = localizedString(.submitButton, LocalizationParameters(enforcedLocale: "is-IS"))

        let warnings = recordWarnings {
            XCTAssertEqual(localizedString(.submitButton, parameters), expected)
        }

        XCTAssertTrue(warnings.isEmpty)
    }

    func test_localizedString_withUnsupportedLocaleAndNoMerchantBundleIntent_shouldFallbackWithoutWarning() {
        let parameters = LocalizationParameters(enforcedLocale: "zu")
        let expected = localizedString(.submitButton, LocalizationParameters(enforcedLocale: "en-US"))

        let warnings = recordWarnings {
            XCTAssertEqual(localizedString(.submitButton, parameters), expected)
        }

        XCTAssertTrue(warnings.isEmpty)
    }

}

// MARK: - Test helpers

private func recordWarnings(_ perform: () -> Void) -> [LocalizationWarning] {
    var warnings = [LocalizationWarning]()
    LocalizationWarningLog.onEmit = { warnings.append($0) }
    perform()
    return warnings
}

private final class MockCheckoutLocalizationProvider: CheckoutLocalizationProvider {

    private let values: [CheckoutLocalizationKey: String]
    private(set) var requestedKeys: [CheckoutLocalizationKey] = []
    private(set) var lastLocale: Locale?

    init(values: [CheckoutLocalizationKey: String]) {
        self.values = values
    }

    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        requestedKeys.append(key)
        lastLocale = locale
        return values[key]
    }
}
