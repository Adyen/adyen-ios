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
        let payload = #"{"CARD_CONFIGURATION":{"showCardholderName":true}}"#
        let encodedPayload = Data(payload.utf8).base64EncodedString()

        let configuration = ExternalConfigurationReader.read(from: ["DemoApp", "-config", encodedPayload])

        XCTAssertEqual(configuration?.card?.showCardholderName, true)
    }

    func test_externalConfigurationReader_withPartialPayload_shouldPreserveNilOptional() {
        let payload = #"{"CARD_CONFIGURATION":{}}"#
        let encodedPayload = Data(payload.utf8).base64EncodedString()

        let configuration = ExternalConfigurationReader.read(from: ["DemoApp", "-config", encodedPayload])

        XCTAssertNil(configuration?.card?.showCardholderName)
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

    func test_externalConfigurationReader_withInvalidBase64_shouldReturnNil() {
        let configuration = ExternalConfigurationReader.read(from: ["DemoApp", "-config", "not-valid-base64!"])

        XCTAssertNil(configuration)
    }
}
