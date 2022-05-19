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
    private var analyticsProviderMock: AnalyticsProviderMock!
    private var context: AdyenContext!

    override func setUp() {
        super.setUp()
    }
    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsProviderMock = AnalyticsProviderMock()
        context = AdyenContext(apiContext: Dummy.apiContext, analyticsProvider: analyticsProviderMock)

        delegate = PaymentComponentDelegateMock()
        paymentMethod = GiftCardPaymentMethod(type: .giftcard, name: "name", brand: "brand")
        sut = InstantPaymentComponent(paymentMethod: paymentMethod,
                                      paymentData: paymentComponentData,
                                            context: context)
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
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
        // When
        sut.initiatePayment()

        // Then
        XCTAssertEqual(analyticsProviderMock.sendTelemetryEventCallsCount, 1)
    }

    // MARK: - Private

    private var paymentComponentData: PaymentComponentData {
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        let amount = Amount(value: 34, currencyCode: "EUR")
        return PaymentComponentData(paymentMethodDetails: details, amount: amount, order: nil)
    }
}
