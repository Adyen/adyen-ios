//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
import XCTest

@MainActor
final class StoredPaymentMethodComponentTests: XCTestCase {

    private var context = Dummy.context

    private let method = StoredPaymentMethodMock(
        identifier: "id",
        supportedShopperInteractions: [.shopperPresent],
        type: .other("type"),
        name: "name"
    )

    // MARK: - Direct submit tests

    func testPerformSubmit_shouldSubmitStoredPaymentDetails() {
        let sut = StoredPaymentMethodComponent(
            paymentMethod: method,
            context: context
        )
        let delegate = PaymentComponentDelegateMock()
        let expectation = expectation(description: "delegate.didSubmit should be called")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNotNil(data.paymentMethod as? StoredPaymentDetails)
            guard let details = data.paymentMethod as? StoredPaymentDetails else {
                XCTFail("Expected StoredPaymentDetails")
                return
            }
            XCTAssertEqual(details.type.rawValue, "type")
            XCTAssertEqual(details.storedPaymentMethodIdentifier, "id")
            expectation.fulfill()
        }
        sut.delegate = delegate

        sut.performSubmit()

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testPerformSubmit_givenDelegateDidFailWithCancellation_shouldForwardError() {
        let sut = StoredPaymentMethodComponent(
            paymentMethod: method,
            context: context
        )
        let delegate = PaymentComponentDelegateMock()
        let expectation = expectation(description: "delegate.didFail should be called")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(error is ComponentError)
            if case ComponentError.cancelled = error {
                // expected
            } else {
                XCTFail("Expected cancelled error")
            }
            expectation.fulfill()
        }
        sut.delegate = delegate

        sut.delegate?.didFail(with: ComponentError.cancelled, from: sut)

        waitForExpectations(timeout: 5, handler: nil)
    }

    // MARK: - Presentability tests

    func testComponent_shouldNotBePresentable() {
        let sut = StoredPaymentMethodComponent(
            paymentMethod: method,
            context: context
        )
        XCTAssertFalse(sut is PresentablePaymentComponent)
    }

    func testComponentType_shouldBeInitiable() {
        let sut = StoredPaymentMethodComponent(
            paymentMethod: method,
            context: context
        )
        if case .initiable = sut.type {
            // expected
        } else {
            XCTFail("Expected initiable component type, got \(sut.type)")
        }
    }
}
