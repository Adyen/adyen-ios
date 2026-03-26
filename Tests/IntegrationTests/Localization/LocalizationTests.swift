//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class LocalizationTests: XCTestCase {

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
}
