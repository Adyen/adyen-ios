//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenCheckout
import AdyenNetworking
@_spi(AdyenInternal) @testable import AdyenSession
import XCTest

final class CheckoutAttemptIdProviderTests: XCTestCase {

    func test_fetchCheckoutAttemptId_returnsCheckoutAttemptId_whenAPIClientSucceeds() async {
        // Given
        let expectedCheckoutAttemptId = "test_checkout_attempt_id_12345"
        let apiClientMock = APIClientMock()
        let response = CheckoutAttemptIdResponse(checkoutAttemptId: expectedCheckoutAttemptId)
        apiClientMock.mockedResults = [.success(response)]

        let sut = CheckoutAttemptIdProvider()

        // When
        let result = await sut.fetchCheckoutAttemptId(with: apiClientMock)

        // Then
        XCTAssertEqual(result, expectedCheckoutAttemptId)
    }

    func test_fetchCheckoutAttemptId_returnsNil_whenAPIClientFails() async {
        // Given
        let apiClientMock = APIClientMock()
        let expectedError = NSError(domain: "TestError", code: 500, userInfo: nil)
        apiClientMock.mockedResults = [.failure(expectedError)]

        let sut = CheckoutAttemptIdProvider()

        // When
        let result = await sut.fetchCheckoutAttemptId(with: apiClientMock)

        // Then
        XCTAssertNil(result)
    }

    func test_fetchCheckoutAttemptId_returnsNil_whenAPIClientIsNil() async {
        let sut = CheckoutAttemptIdProvider()

        // When
        let result = await sut.fetchCheckoutAttemptId(with: nil)

        // Then
        XCTAssertNil(result)
    }
}
