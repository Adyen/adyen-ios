//
//  InstantPaymentComponentTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 5/20/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class InstantPaymentComponentTests: XCTestCase {

    private var paymentMethod: GiftCardPaymentMethod!
    private var delegate: PaymentComponentDelegateMock!
    private var sut: InstantPaymentComponent!
    private var context: AdyenContext!

    override func setUp() {
        super.setUp()
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context

        delegate = PaymentComponentDelegateMock()
        paymentMethod = GiftCardPaymentMethod(type: .giftcard, name: "name", brand: "brand")
        sut = InstantPaymentComponent(paymentMethod: paymentMethod,
                                      context: context,
                                      paymentData: paymentComponentData)
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        context = nil
        paymentMethod = nil
        delegate = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testCustomPaymentData() throws {
        let delegateExpectation = expectation(description: "expect delegate to be called.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === self.sut)
            let details = data.paymentMethod as! GiftCardDetails
            XCTAssertEqual(details.brand, "brand")
            XCTAssertEqual(details.encryptedCardNumber, "card")
            XCTAssertEqual(details.encryptedSecurityCode, "cvc")
            delegateExpectation.fulfill()
        }

        sut.initiatePayment()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testInitiatePaymentShouldSendTelemetryEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        sut = InstantPaymentComponent(paymentMethod: paymentMethod,
                                      context: context,
                                      paymentData: paymentComponentData)

        // When
        sut.initiatePayment()

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }

    // MARK: - Private

    private var paymentComponentData: PaymentComponentData {
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        return PaymentComponentData(paymentMethodDetails: details, amount: nil, order: nil)
    }
}
