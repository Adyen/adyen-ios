//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn
@testable import AdyenUI
import XCTest

final class DropInConfigurationTests: XCTestCase {

    func test_init_shouldUseDefaultValues() {
        let sut = DropInConfiguration()

        XCTAssertFalse(sut.hideStoredPaymentMethods)
        XCTAssertTrue(sut.startWithLastStoredPaymentMethod)
    }

    func test_fluentMethods_shouldReturnModifiedCopies() {
        let original = DropInConfiguration()

        let modified = original
            .hideStoredPaymentMethods(true)
            .startWithLastStoredPaymentMethod(false)

        XCTAssertFalse(original.hideStoredPaymentMethods)
        XCTAssertTrue(original.startWithLastStoredPaymentMethod)
        XCTAssertTrue(modified.hideStoredPaymentMethods)
        XCTAssertFalse(modified.startWithLastStoredPaymentMethod)
    }

    func test_init_shouldConformToCheckoutConfigurable() {
        let sut: any CheckoutConfigurable = DropInConfiguration()

        XCTAssertTrue(sut is DropInConfiguration)
    }

    func test_localizationProvider_shouldResolveLegacyLocalizationParameters() throws {
        let provider = DropInLocalizationProviderMock()
        var sut = DropInConfiguration()
        sut.localizationProvider = provider

        let parameters = try XCTUnwrap(sut.resolvedLocalizationParameters)
        let resolvedProvider = try XCTUnwrap(parameters.provider as? DropInLocalizationProviderMock)

        XCTAssertTrue(resolvedProvider === provider)
    }

    func test_analyticsConfiguration_shouldUseUnconditionalPaymentListSkipping() throws {
        let configuration = DropInConfiguration().startWithLastStoredPaymentMethod(false)

        let sut = try XCTUnwrap(DropInAnalyticsConfiguration(configuration: configuration).stringOnlyDictionary)

        XCTAssertEqual(sut["skipPaymentMethodList"], "true")
        XCTAssertEqual(sut["openFirstStoredPaymentMethod"], "false")
    }
}

private final class DropInLocalizationProviderMock: CheckoutLocalizationProvider {
    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        nil
    }
}
