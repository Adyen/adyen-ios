//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
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
        sut = PaymentComponentSubject(
            context: context,
            delegate: paymentComponentDelegate,
            payment: payment,
            order: nil,
            paymentMethod: paymentMethod
        )
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
        analyticsProviderMock.checkoutAttemptId = expectedCheckoutAttemptId
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)

        let didSubmitExpectation = expectation(description: "didSubmit should get called")
        
        // When
        XCTAssertNil(paymentComponentData.checkoutAttemptId)

        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertEqual(expectedCheckoutAttemptId, data.checkoutAttemptId)
            didSubmitExpectation.fulfill()
        }
        
        sut.submit(data: paymentComponentData, component: sut)
        
        wait(for: [didSubmitExpectation], timeout: 3)
    }

    func testSubmitWithNoAttemptIdShouldSetConstantInPaymentComponentData() throws {
        // Given
        analyticsProviderMock.checkoutAttemptId = nil
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)

        let didSubmitExpectation = expectation(description: "didSubmit should get called")
        
        // When
        XCTAssertNil(paymentComponentData.checkoutAttemptId)
        
        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertEqual(data.checkoutAttemptId, "fetch-checkoutAttemptId-failed")
            didSubmitExpectation.fulfill()
        }
        
        sut.submit(data: paymentComponentData, component: sut)
        
        wait(for: [didSubmitExpectation], timeout: 3)
    }

    func testSubmitWhenBrowserInfoIsNilShouldSetBrowserInfoInPaymentComponentData() throws {
        // Given
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)

        let didSubmitExpectation = expectation(description: "didSubmit should get called")
        
        // When
        XCTAssertNil(paymentComponentData.browserInfo)

        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertNotNil(data.browserInfo)
            didSubmitExpectation.fulfill()
        }
        
        sut.submit(data: paymentComponentData, component: sut)
        
        wait(for: [didSubmitExpectation], timeout: 3)
    }

    func testSubmitWhenBrowserInfoIsNotNilShouldNotSetBrowserInfoInPaymentComponentData() throws {
        // Given
        let expectedBrowserInfo = BrowserInfo(userAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko)")
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(
            paymentMethodDetails: paymentMethodDetails,
            amount: nil,
            order: nil,
            browserInfo: expectedBrowserInfo
        )
        
        let didSubmitExpectation = expectation(description: "didSubmit should get called")

        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertNotNil(data.browserInfo)
            XCTAssertEqual(expectedBrowserInfo.userAgent, data.browserInfo?.userAgent)
            didSubmitExpectation.fulfill()
        }
        
        sut.submit(data: paymentComponentData, component: sut)
        
        wait(for: [didSubmitExpectation], timeout: 3)
    }
    
    func testSubmitEvent() throws {
        let expectedCheckoutAttemptId = "d06da733-ec41-4739-a532-5e8deab1262e16547639430681e1b021221a98c4bf13f7366b30fec4b376cc8450067ff98998682dd24fc9bda"
        analyticsProviderMock._checkoutAttemptId = expectedCheckoutAttemptId
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)
        
        let didSubmitExpectation = expectation(description: "didSubmit should get called")
        
        paymentComponentDelegate.onDidSubmit = { data, _ in
            let submitEvent = self.analyticsProviderMock.logs[0]
            XCTAssertEqual(submitEvent.type, .submit)
            didSubmitExpectation.fulfill()
        }

        sut.submit(data: paymentComponentData, component: sut)
        
        wait(for: [didSubmitExpectation], timeout: 3)
    }
}
