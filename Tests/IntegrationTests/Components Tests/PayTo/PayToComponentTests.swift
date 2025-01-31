//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class PayToComponentTests: XCTestCase {

    func test_init() throws {
        let sut = try PayToComponent(
            paymentMethod: AdyenCoder.decode(payto),
            context: Dummy.context
        )

        XCTAssertNotNil(sut)
    }

    func test_paymentMethodType_isPayto() throws {
        let sut = try PayToComponent(
            paymentMethod: AdyenCoder.decode(payto),
            context: Dummy.context
        )

        XCTAssertEqual(sut.paymentMethod.type, .payto)
    }
}
