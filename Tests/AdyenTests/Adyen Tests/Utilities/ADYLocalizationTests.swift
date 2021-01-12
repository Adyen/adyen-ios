//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class ADYLocalizationTests: XCTestCase {
    // MARK: - Button title

    func testLocalizationWitZeroPayment() {
        XCTAssertEqual(ADYLocalizedSubmitButtonTitle(with: Payment.Amount(value: 0, currencyCode: "EUR"), style: .needsRedirectToThirdParty("test_name"), nil), "Preauthorize with test_name")

        XCTAssertEqual(ADYLocalizedSubmitButtonTitle(with: Payment.Amount(value: 0, currencyCode: "EUR"), style: .immediate, nil), "Confirm preauthorization")
    }
    
    // MARK: - Custom Recognized TableName
    
    /// Default Separator
    func testLocalizationWithCustomRecognizedTableNameAndDefaultSeparator() {
        let parameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "Test-Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "Test-Verify your card")
    }

    /// Unrecognized Separator
    func testLocalizationWithCustomRecognizedTableNameAndCustomUnrecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: "*")
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "Test-Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "Test-Verify your card")
    }

    /// Recognized Separator
    func testLocalizationWithCustomRecognizedTableNameAndCustomRecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "Test-Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "Test-Verify your card")
    }

    // MARK: - Custom Bundle

    func testLocalizationWithCustomRecognizedTableNameAndDefaultSeparatorAndCustomBundle() {
        let parameters = LocalizationParameters(bundle: Bundle(for: ADYLocalizationTests.self),
                                                tableName: "AdyenTests",
                                                keySeparator: nil)
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "TestBundle-Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "TestBundle-Verify your card")
    }

    func testLocalizationWithCustomBundleFallbackToMainBundle() {
        let parameters = LocalizationParameters(bundle: Bundle(for: ADYLocalizationTests.self),
                                                tableName: nil,
                                                keySeparator: nil)
        XCTAssertEqual(ADYLocalizedString("any.key.1", parameters, "test"), "value 1 test")
        XCTAssertEqual(ADYLocalizedString("any.key.2", parameters), "value 2")
    }

    func testLocalizationWithCustomBundleFallbackToSDKBundle() {
        let parameters = LocalizationParameters(bundle: Bundle(for: ADYLocalizationTests.self),
                                                tableName: nil,
                                                keySeparator: nil)
        XCTAssertEqual(ADYLocalizedString("adyen.blik.placeholder", parameters), "123–456")
    }

    func testLocalizationWithCustomRecognizedTableNameAndCustomRecognizedSeparatorAndCustomBundle() {
        let parameters = LocalizationParameters(bundle: Bundle(for: ADYLocalizationTests.self),
                                                tableName: "AdyenTestsCustomSeparator",
                                                keySeparator: "_")
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "TestBundle-Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "TestBundle-Verify your card")
    }
    
    // MARK: - Custom Unrecognized TableName
    
    /// Default Separator
    func testLocalizationWithCustomUnrecognizedTableNameAndDefaultSeparator() {
        let parameters = LocalizationParameters(tableName: "123", keySeparator: nil)
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "Verify your card")
    }
    
    /// Unrecognized Separator
    func testLocalizationWithCustomUnrecognizedTableNameAndCustomUnrecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: "123", keySeparator: "*")
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "Verify your card")
    }
    
    /// Recognized Separator
    func testLocalizationWithCustomUnrecognizedTableNameAndCustomRecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: "123", keySeparator: "_")
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "Verify your card")
    }
    
    // MARK: - SDK bundle default TableName
    
    /// Default Separator
    func testLocalizationWithDefaultTableNameAndDefaultSeparator() {
        let parameters = LocalizationParameters(tableName: nil, keySeparator: nil)
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "Verify your card")
    }
    
    /// Unrecognized Separator
    func testLocalizationWithDefaultTableNameAndCustomUnrecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: nil, keySeparator: "*")
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "Verify your card")
    }
    
    /// Recognized Separator
    func testLocalizationWithDefaultTableNameAndCustomRecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: nil, keySeparator: "_")
        XCTAssertEqual(ADYLocalizedString("adyen.dropIn.stored.title", parameters, "test"), "Confirm test payment")
        XCTAssertEqual(ADYLocalizedString("adyen.card.stored.title", parameters), "Verify your card")
    }
    
    // MARK: - App bundle default TableName
    
    /// Default Separator
    func testLocalizationWithDefaultAppBundleTableNameAndDefaultSeparator() {
        let parameters = LocalizationParameters(tableName: nil, keySeparator: nil)
        XCTAssertEqual(ADYLocalizedString("any.key.1", parameters, "test"), "value 1 test")
        XCTAssertEqual(ADYLocalizedString("any.key.2", parameters), "value 2")
    }
    
    /// Unrecognized Separator
    func testLocalizationWithDefaultAppBundleTableNameAndUnrecognizedSeparator() {
        let parameters = LocalizationParameters(tableName: nil, keySeparator: "*")
        XCTAssertEqual(ADYLocalizedString("any.key.1", parameters, "test"), "value 1 test")
        XCTAssertEqual(ADYLocalizedString("any.key.2", parameters), "value 2")
    }
}
