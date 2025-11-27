//
// Copyright (c) 2025 Adyen N.V.
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

    func test_submit_with_no_attemptId_sets_constant_in_sdkData() throws {
        // Given
        analyticsProviderMock.checkoutAttemptId = nil
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)

        let didSubmitExpectation = expectation(description: "didSubmit should get called")
        
        // When
        XCTAssertNil(paymentComponentData.paymentMethod.sdkData)
        
        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertNotNil(data.paymentMethod.sdkData)
            
            guard let sdkDataDecoded = self.sdkData(from: data.paymentMethod.sdkData) else {
                XCTFail("SDKData should be present and decodable")
                return
            }
            
            XCTAssertEqual(sdkDataDecoded.analytics.checkoutAttemptId, "fetch-checkoutAttemptId-failed")
            XCTAssertEqual(data.checkoutAttemptId, "fetch-checkoutAttemptId-failed")
            didSubmitExpectation.fulfill()
        }
        
        sut.submit(data: paymentComponentData, component: sut)
        
        wait(for: [didSubmitExpectation], timeout: 3)
    }

    func test_submit_sets_browserInfo() throws {
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
    
    func test_submit_event() throws {
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
    
    // MARK: - SDKData Tests
    
    func test_submit_creates_sdkData_with_analytics() throws {
        // Given
        let expectedCheckoutAttemptId = "d06da733-ec41-4739-a532-5e8deab1262e16547639430681e1b021221a98c4bf13f7366b30fec4b376cc8450067ff98998682dd24fc9bda"
        analyticsProviderMock.checkoutAttemptId = expectedCheckoutAttemptId
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)

        let didSubmitExpectation = expectation(description: "didSubmit should get called")
        
        // When
        XCTAssertNil(paymentComponentData.paymentMethod.sdkData)

        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertNotNil(data.paymentMethod.sdkData)
            
            guard let sdkDataDecoded = self.sdkData(from: data.paymentMethod.sdkData) else {
                XCTFail("SDKData should be present and decodable")
                return
            }
            
            // Verify SDKData contains checkoutAttemptId
            XCTAssertEqual(sdkDataDecoded.analytics.checkoutAttemptId, expectedCheckoutAttemptId)
            XCTAssertEqual(sdkDataDecoded.schemaVersion, 1)
            // Verify through the deprecated property for backward compatibility
            XCTAssertEqual(data.checkoutAttemptId, expectedCheckoutAttemptId)
            didSubmitExpectation.fulfill()
        }
        
        sut.submit(data: paymentComponentData, component: sut)
        
        wait(for: [didSubmitExpectation], timeout: 3)
    }
    
    func test_submit_with_authenticationProvider_includes_authentication_in_sdkData() throws {
        // Given
        let expectedCheckoutAttemptId = "test-checkout-attempt-id"
        analyticsProviderMock.checkoutAttemptId = expectedCheckoutAttemptId
        
        // Create a mock payment method that provides authentication
        let mockAuthProvider = MockSDKDataAuthenticationProvider()
        let paymentMethodDetails = MockAuthenticationPaymentDetails(authProvider: mockAuthProvider)
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)
        
        let didSubmitExpectation = expectation(description: "didSubmit should get called")
        
        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertNotNil(data.paymentMethod.sdkData, "SDKData should be created")
            
            guard let sdkDataDecoded = self.sdkData(from: data.paymentMethod.sdkData) else {
                XCTFail("SDKData should be present and decodable")
                return
            }
            
            // Verify the SDKData contains authentication
            XCTAssertNotNil(sdkDataDecoded.authentication)
            XCTAssertEqual(sdkDataDecoded.authentication?.threeDS2SdkVersion, "0.0.0")
            didSubmitExpectation.fulfill()
        }
        
        sut.submit(data: paymentComponentData, component: sut)
        
        wait(for: [didSubmitExpectation], timeout: 3)
    }
    
    func test_submit_without_authenticationProvider_includes_only_analytics_in_sdkData() throws {
        // Given
        let expectedCheckoutAttemptId = "test-checkout-attempt-id"
        analyticsProviderMock.checkoutAttemptId = expectedCheckoutAttemptId
        
        // Use a payment method that doesn't provide authentication
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)
        
        let didSubmitExpectation = expectation(description: "didSubmit should get called")
        
        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            
            guard let sdkDataDecoded = self.sdkData(from: data.paymentMethod.sdkData) else {
                XCTFail("SDKData should be present and decodable")
                return
            }
            
            XCTAssertEqual(sdkDataDecoded.analytics.checkoutAttemptId, expectedCheckoutAttemptId)
            XCTAssertNil(sdkDataDecoded.authentication)
            didSubmitExpectation.fulfill()
        }
        
        sut.submit(data: paymentComponentData, component: sut)
        
        wait(for: [didSubmitExpectation], timeout: 3)
    }
    
    func test_submit_includes_sdkData_other_fields() throws {
        // Given
        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)
        
        let didSubmitExpectation = expectation(description: "didSubmit should get called")
        
        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            XCTAssertNotNil(data.paymentMethod.sdkData)
            
            // Verify timestamp is present
            guard let sdkDataString = data.paymentMethod.sdkData,
                  let decodedData = Data(base64Encoded: sdkDataString),
                  let jsonString = String(data: decodedData, encoding: .utf8) else {
                XCTFail("SDKData should be present and decodable to a string")
                return
            }
            XCTAssertTrue(jsonString.contains("\"createdAt\""), "SDKData should contain the createdAt timestamp")
            XCTAssertTrue(jsonString.contains("\"supportNativeRedirect\""), "SDKData should contain supportNativeRedirect ")
            didSubmitExpectation.fulfill()
        }
        
        sut.submit(data: paymentComponentData, component: sut)
        
        wait(for: [didSubmitExpectation], timeout: 3)
    }
    
    private func sdkData(from sdkDataString: String?) -> SDKData? {
        guard let sdkDataString,
              let sdkDataDecoded: SDKData = try? AdyenCoder.decodeBase64(sdkDataString) else {
            XCTFail("SDKData should be present and decodable")
            return nil
        }
        return sdkDataDecoded
    }
}

// MARK: - Test Helpers

private class MockSDKDataAuthenticationProvider: SDKDataAuthenticationProvider {
    var authentication: SDKData.Authentication {
        SDKData.Authentication(threeDS2SdkVersion: "0.0.0")
    }
}

private struct MockAuthenticationPaymentDetails: PaymentMethodDetails, SDKDataAuthenticationProvider {
    let type: PaymentMethodType = .scheme
    var checkoutAttemptId: String?
    let authProvider: MockSDKDataAuthenticationProvider
    var sdkData: String?
    
    var authentication: SDKData.Authentication {
        authProvider.authentication
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
}
