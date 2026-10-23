//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenUIHost
import XCTest

final class DemoConfigurationTests: XCTestCase {

    private var defaultConfiguration: DemoAppSettings {
        DemoAppSettings(
            countryCode: "NL",
            value: 17408,
            currencyCode: "EUR",
            merchantAccount: "merchantAccount",
            cardSettings: DemoAppSettings.defaultCardSettings,
            dropInSettings: DemoAppSettings.defaultDropInSettings,
            threeDSConfigurationSettings: DemoAppSettings.threeDSConfigurationSettings,
            applePaySettings: ApplePaySettings(merchantIdentifier: "demo"),
            analyticsSettings: DemoAppSettings.defaultAnalyticsSettings,
            themeSettings: DemoAppSettings.defaultThemeSettings
        )
    }

    private func base64Encode(_ configuration: ExternalConfiguration) -> String {
        try! JSONEncoder().encode(configuration).base64EncodedString()
    }

    func test_configuration_withExternalConfiguration_shouldApplyItToDefaults() {
        var persistedCardSettings = defaultConfiguration.cardSettings
        persistedCardSettings.enableInstallments = true
        let persistedConfiguration = DemoAppSettings(
            countryCode: "US",
            value: 100,
            currencyCode: "USD",
            merchantAccount: "persistedMerchant",
            cardSettings: persistedCardSettings,
            dropInSettings: defaultConfiguration.dropInSettings,
            threeDSConfigurationSettings: defaultConfiguration.threeDSConfigurationSettings,
            applePaySettings: defaultConfiguration.applePaySettings,
            analyticsSettings: defaultConfiguration.analyticsSettings,
            themeSettings: defaultConfiguration.themeSettings
        )
        let externalConfiguration = ExternalConfiguration(
            card: ExternalCardConfiguration(showCardholderName: true)
        )

        let configuration = DemoAppSettings.resolveConfiguration(
            persisted: persistedConfiguration,
            external: externalConfiguration,
            default: defaultConfiguration
        )

        XCTAssertTrue(configuration.cardSettings.showCardholderName)
        XCTAssertFalse(configuration.cardSettings.enableInstallments)
        XCTAssertEqual(configuration.countryCode, defaultConfiguration.countryCode)
        XCTAssertEqual(configuration.currencyCode, defaultConfiguration.currencyCode)
        XCTAssertEqual(configuration.value, defaultConfiguration.value)
    }

    func test_externalConfigurationReader_withValidPayload_shouldDecodeCardholderName() {
        let configuration = ExternalConfiguration(
            card: ExternalCardConfiguration(showCardholderName: true)
        )
        let encodedPayload = base64Encode(configuration)

        let result = ExternalConfigurationReader.read(from: ["DemoApp", "-config", encodedPayload])

        XCTAssertEqual(result?.card?.showCardholderName, true)
    }

    func test_externalConfigurationReader_withEmptyCardConfiguration_shouldPreserveNilOptional() {
        let encodedPayload = base64Encode(ExternalConfiguration(card: ExternalCardConfiguration()))

        let result = ExternalConfigurationReader.read(from: ["DemoApp", "-config", encodedPayload])

        XCTAssertNil(result?.card?.showCardholderName)
    }

    func test_externalConfigurationReader_withoutConfigArgument_shouldReturnNil() {
        let configuration = ExternalConfigurationReader.read(from: ["DemoApp"])

        XCTAssertNil(configuration)
    }

    func test_externalConfigurationReader_withoutConfigValue_shouldReturnNil() {
        let configuration = ExternalConfigurationReader.read(from: ["DemoApp", "-config"])

        XCTAssertNil(configuration)
    }

    func test_configuration_withoutExternalConfiguration_shouldUsePersistedConfiguration() {
        var persistedConfiguration = defaultConfiguration
        persistedConfiguration.countryCode = "US"
        persistedConfiguration.currencyCode = "USD"

        let configuration = DemoAppSettings.resolveConfiguration(
            persisted: persistedConfiguration,
            external: nil,
            default: defaultConfiguration
        )

        XCTAssertEqual(configuration.countryCode, persistedConfiguration.countryCode)
        XCTAssertEqual(configuration.currencyCode, persistedConfiguration.currencyCode)
        XCTAssertEqual(configuration.value, persistedConfiguration.value)
    }

    func test_externalConfigurationReader_withMalformedJSON_shouldReturnNil() {
        let encodedPayload = Data("this is not valid json".utf8).base64EncodedString()

        let result = ExternalConfigurationReader.read(from: ["DemoApp", "-config", encodedPayload])

        XCTAssertNil(result)
    }

    func test_externalConfigurationReader_withInvalidBase64_shouldReturnNil() {
        let configuration = ExternalConfigurationReader.read(from: ["DemoApp", "-config", "not-valid-base64!"])

        XCTAssertNil(configuration)
    }

    func test_externalConfigurationReader_withDropInConfiguration_shouldDecodeStoredPaymentMethodFlags() {
        let configuration = ExternalConfiguration(
            dropIn: ExternalDropInConfiguration(hideStoredPaymentMethods: true, startWithLastStoredPaymentMethod: false)
        )
        let encodedPayload = base64Encode(configuration)

        let result = ExternalConfigurationReader.read(from: ["DemoApp", "-config", encodedPayload])

        XCTAssertEqual(result?.dropIn?.hideStoredPaymentMethods, true)
        XCTAssertEqual(result?.dropIn?.startWithLastStoredPaymentMethod, false)
    }

    func test_applying_withDropInConfiguration_shouldOverrideStoredPaymentMethodFlags() {
        let external = ExternalConfiguration(
            dropIn: ExternalDropInConfiguration(hideStoredPaymentMethods: true, startWithLastStoredPaymentMethod: false)
        )

        let configuration = defaultConfiguration.applying(external)

        XCTAssertTrue(configuration.dropInSettings.hideStoredPaymentMethods)
        XCTAssertFalse(configuration.dropInSettings.startWithLastStoredPaymentMethod)
    }

    func test_applying_withPartialDropInConfiguration_shouldKeepUnsetDropInDefaults() {
        let external = ExternalConfiguration(
            dropIn: ExternalDropInConfiguration(startWithLastStoredPaymentMethod: false)
        )

        let configuration = defaultConfiguration.applying(external)

        XCTAssertFalse(configuration.dropInSettings.hideStoredPaymentMethods)
        XCTAssertFalse(configuration.dropInSettings.startWithLastStoredPaymentMethod)
        XCTAssertEqual(
            configuration.dropInSettings.showRemovePaymentMethodButton,
            defaultConfiguration.dropInSettings.showRemovePaymentMethodButton
        )
    }

    func test_externalConfigurationReader_withApplePayConfiguration_shouldDecodePlainPaymentSheet() {
        let configuration = ExternalConfiguration(
            applePay: ExternalApplePayConfiguration(plainPaymentSheet: true)
        )
        let encodedPayload = base64Encode(configuration)

        let result = ExternalConfigurationReader.read(from: ["DemoApp", "-config", encodedPayload])

        XCTAssertEqual(result?.applePay?.plainPaymentSheet, true)
    }

    func test_externalConfigurationReader_withApplePayConfigurationJSON_shouldUseApplePayConfigurationKey() {
        let json = #"{"APPLE_PAY_CONFIGURATION":{"plainPaymentSheet":true}}"#
        let encodedPayload = Data(json.utf8).base64EncodedString()

        let result = ExternalConfigurationReader.read(from: ["DemoApp", "-config", encodedPayload])

        XCTAssertEqual(result?.applePay?.plainPaymentSheet, true)
    }

    func test_applying_withApplePayConfiguration_shouldOverridePlainPaymentSheet() {
        let external = ExternalConfiguration(
            applePay: ExternalApplePayConfiguration(plainPaymentSheet: true)
        )

        let configuration = defaultConfiguration.applying(external)

        XCTAssertTrue(configuration.applePaySettings.plainPaymentSheet)
        XCTAssertEqual(configuration.applePaySettings.merchantIdentifier, defaultConfiguration.applePaySettings.merchantIdentifier)
        XCTAssertEqual(configuration.applePaySettings.onBeforeSubmitMode, defaultConfiguration.applePaySettings.onBeforeSubmitMode)
    }

    func test_applying_withoutApplePayConfiguration_shouldKeepFullPaymentSheet() {
        let configuration = defaultConfiguration.applying(ExternalConfiguration())

        XCTAssertFalse(configuration.applePaySettings.plainPaymentSheet)
    }
}
