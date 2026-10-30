//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenUI
import XCTest

final class ComponentConfigurationCallbacksValidationTests: XCTestCase {

    func test_cardConfiguration_withLookupAndNoAddressCallbacks_shouldThrowInvalidConfiguration() {
        let configuration = CardConfiguration().billingAddressMode(.lookup())

        XCTAssertThrowsError(try configuration.validate(AdditionalCallbacksStore([CardCallbacks()]))) { error in
            XCTAssertEqual((error as? CheckoutError)?.code, .invalidConfiguration)
        }
    }

    func test_cardConfiguration_withLookupAndAddressCallbacks_shouldNotThrow() {
        let configuration = CardConfiguration().billingAddressMode(.lookup())
        let callbacks = AdditionalCallbacksStore([AddressCallbacks(onAddressLookup: { _ in [] })])

        XCTAssertNoThrow(try configuration.validate(callbacks))
    }

    func test_cardConfiguration_withoutLookup_shouldNotRequireAddressCallbacks() {
        let modes: [BillingAddressMode] = [.none, .postalCode(), .full()]

        for mode in modes {
            XCTAssertNoThrow(try CardConfiguration().billingAddressMode(mode).validate(AdditionalCallbacksStore()), "\(mode)")
        }
    }

    func test_validate_throughTypeErasedConfiguration_shouldUseConformingTypeImplementation() {
        let configuration: any CheckoutComponentConfiguration = CardConfiguration().billingAddressMode(.lookup())

        XCTAssertThrowsError(try configuration.validate(AdditionalCallbacksStore()))
    }

    func test_validate_withoutRequiredCallbacks_shouldNotThrow() {
        let configuration: any CheckoutComponentConfiguration = BasicComponentConfiguration()

        XCTAssertNoThrow(try configuration.validate(AdditionalCallbacksStore()))
    }
}
