//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

final class LocalizationTableCompletenessValidatorTests: XCTestCase {

    func test_sdkLocalizableTable_shouldContainAllKeysForAllSupportedLocales() throws {
        let validator = LocalizationTableCompletenessValidator()

        let missingKeys = try validator.missingKeys(
            in: Bundle.coreInternalResources,
            tableName: nil,
            sourceLocale: "en-US"
        )

        let errorDetails = missingKeys
            .map { "\($0.locale): \($0.keys.joined(separator: ", "))" }
            .joined(separator: "\n")

        XCTAssertTrue(
            missingKeys.isEmpty,
            """
            Missing localization keys detected in SDK Localizable table.
            \(errorDetails)
            """
        )
    }

    func test_validator_withExplicitTableName_shouldMatchDefaultTableResults() throws {
        let validator = LocalizationTableCompletenessValidator()
        let supportedLocales = try validator.supportedLocales(in: Bundle.coreInternalResources)

        let missingForDefault = try validator.missingKeys(
            in: Bundle.coreInternalResources,
            tableName: nil,
            sourceLocale: "en-US",
            locales: supportedLocales
        )

        let missingForExplicitTable = try validator.missingKeys(
            in: Bundle.coreInternalResources,
            tableName: "Localizable",
            sourceLocale: "en-US",
            locales: supportedLocales
        )

        XCTAssertEqual(missingForDefault, missingForExplicitTable)
    }
}
