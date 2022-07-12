//
//  PaymentComponentSubjectTests.swift
//  AdyenUIKitTests
//
//  Created by Naufal Aros on 09/06/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents

class PaymentComponentSubjectTests: XCTestCase {

    var analyticsProviderMock: AnalyticsProviderMock!
    var context: AdyenContext!
    var paymentComponentDelegate: PaymentComponentDelegateMock!
    var payment = Dummy.payment
    var paymentMethod = MBWayPaymentMethod(type: .mbWay, name: "MBWay")
    var sut: PaymentComponentSubject!

    override func setUpWithError() throws {
        try super.setUpWithError()

        analyticsProviderMock = AnalyticsProviderMock()
        context = Dummy.context(with: analyticsProviderMock)
        paymentComponentDelegate = PaymentComponentDelegateMock()
        sut = PaymentComponentSubject(context: context,
                                      delegate: paymentComponentDelegate,
                                      payment: payment,
                                      order: nil,
                                      paymentMethod: paymentMethod)
    }

    override func tearDownWithError() throws {
        context = nil
        paymentComponentDelegate = nil
        sut = nil
        analyticsProviderMock = nil
        try super.tearDownWithError()
    }

    func testSubmitWithAnalyticsEnabledShouldSetCheckoutAttemptIdInPaymentComponentData() throws {
        // Given
        let expectedCheckoutAttemptId = "d06da733-ec41-4739-a532-5e8deab1262e16547639430681e1b021221a98c4bf13f7366b30fec4b376cc8450067ff98998682dd24fc9bda"
        analyticsProviderMock.underlyingCheckoutAttemptId = expectedCheckoutAttemptId
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)

        // When
        XCTAssertNil(paymentComponentData.checkoutAttemptId)
        sut.submit(data: paymentComponentData, component: sut)

        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertEqual(expectedCheckoutAttemptId, data.checkoutAttemptId)
        }
    }

    func testSubmitWithAnalyticsDisabledShouldNotSetCheckoutAttemptIdInPaymentComponentData() throws {
        // Given
        analyticsProviderMock.underlyingCheckoutAttemptId = nil
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)

        // When
        XCTAssertNil(paymentComponentData.checkoutAttemptId)
        sut.submit(data: paymentComponentData, component: sut)

        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertNil(data.checkoutAttemptId)
        }
    }

    func testSubmitWhenBrowserInfoIsNilShouldSetBrowserInfoInPaymentComponentData() throws {
        // Given
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)

        // When
        XCTAssertNil(paymentComponentData.browserInfo)
        sut.submit(data: paymentComponentData, component: sut)

        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertNotNil(data.browserInfo)
        }
    }

    func testSubmitWhenBrowserInfoIsNotNilShouldNotSetBrowserInfoInPaymentComponentData() throws {
        // Given
        let expectedBrowserInfo = BrowserInfo(userAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko)")
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails,
                                                        amount: nil,
                                                        order: nil,
                                                        browserInfo: expectedBrowserInfo)

        // When
        sut.submit(data: paymentComponentData, component: sut)

        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertNotNil(data.browserInfo)
            XCTAssertEqual(expectedBrowserInfo.userAgent, data.browserInfo?.userAgent)
        }
    }
}
