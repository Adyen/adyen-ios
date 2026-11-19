//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardBrandProviderTests: XCTestCase {

    private enum Constants {
        static let throttlingDelay: TimeInterval = 0.1
    }

    var apiClientMock: APIClientMock!
    var sut: BinInfoProvider!

    override func setUp() {
        apiClientMock = APIClientMock()
        sut = BinInfoProvider(
            apiClient: apiClientMock,
            adyenContext: Dummy.context,
            minBinLength: 11,
            binLookupType: .card,
            binLookupThrottler: Throttler(minimumDelay: Constants.throttlingDelay)
        )
    }

    override func tearDown() {
        apiClientMock = nil
        sut = nil
    }

    func testLocalCardBrandFetch() {
        apiClientMock.onExecute = { _ in
            XCTFail("Should not call APIClient")
        }

        sut.provide(for: "56", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.brand), [.maestro])
        }
    }

    func testRemoteCardBrandFetch() {
        let mockedBrands = [DetectedCardBrand(brand: .solo)]
        apiClientMock.mockedResults = [.success(BinLookupResponse(brands: mockedBrands))]

        let completion = expectation(description: "Provider completes with remote brands")

        sut.provide(for: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.brand), [.solo])
            completion.fulfill()
        }

        wait(for: [completion], timeout: 1)
    }

    func testRemoteCardBrandFetchWithAPIFailure() {
        apiClientMock.mockedResults = [.failure(Dummy.error)]
        let completion = expectation(description: "Provider completes with fallback brands")

        sut.provide(for: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.brand), [.maestro])
            completion.fulfill()
        }

        wait(for: [completion], timeout: 1)
    }

    func test_provide_whenBinChangesRapidlyAboveMinLength_shouldRequestBinLookupOnce() {
        apiClientMock.mockedResults = [.success(BinLookupResponse(brands: [DetectedCardBrand(brand: .visa)]))]
        let completion = expectation(description: "Provider completes once with remote brands")
        let supportedTypes: [CardBrand] = [.masterCard, .visa]

        sut.provide(for: "41111111111", supportedTypes: supportedTypes) { _ in completion.fulfill() }
        sut.provide(for: "411111111111", supportedTypes: supportedTypes) { _ in completion.fulfill() }
        sut.provide(for: "4111111111111", supportedTypes: supportedTypes) { _ in completion.fulfill() }

        XCTAssertEqual(apiClientMock.counter, 0)
        wait(for: [completion], timeout: 1)
        XCTAssertEqual(apiClientMock.counter, 1)
    }

    func test_provide_whenBinShortenedBelowMinLength_shouldCancelPendingBinLookup() {
        apiClientMock.onExecute = { _ in
            XCTFail("Should not call APIClient")
        }
        let completion = expectation(description: "Provider completes with local brands")
        let supportedTypes: [CardBrand] = [.masterCard, .visa]

        sut.provide(for: "41111111111", supportedTypes: supportedTypes) { _ in
            XCTFail("Should not complete the cancelled /binlookup request")
        }
        sut.provide(for: "4111", supportedTypes: supportedTypes) { response in
            XCTAssertEqual(response.brands?.map(\.brand), [.visa])
            completion.fulfill()
        }

        wait(for: [completion], timeout: 1)
        wait(for: .milliseconds(300))
        XCTAssertEqual(apiClientMock.counter, 0)
    }

    func test_fallbackBinInfoProvider_whenDetectingBrandLocally_shouldReturnUnreliableBrands() {
        let completion = expectation(description: "Fallback provider completes")
        FallbackBinInfoProvider().provide(for: "4111", supportedTypes: [.visa]) { response in
            XCTAssertEqual(response.brands?.map(\.brand), [.visa])
            XCTAssertEqual(response.brands?.map(\.isReliable), [false])
            completion.fulfill()
        }
        wait(for: [completion], timeout: 1)
    }

    func test_provide_whenBinLookupFails_shouldReturnUnreliableBrands() {
        apiClientMock.mockedResults = [.failure(Dummy.error)]
        let completion = expectation(description: "Provider completes with fallback brands")

        sut.provide(for: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro]) { response in
            XCTAssertTrue(response.isCreatedLocally)
            XCTAssertEqual(response.brands?.map(\.brand), [.maestro])
            XCTAssertEqual(response.brands?.map(\.isReliable), [false])
            completion.fulfill()
        }

        wait(for: [completion], timeout: 1)
        XCTAssertEqual(apiClientMock.counter, 1)
    }

    func test_detectedCardBrand_whenDecodedFromBinLookupResponse_shouldBeReliable() throws {
        let json = """
        {
            "requestId": "request_id",
            "issuingCountryCode": "US",
            "brands": [
                {
                    "brand": "visa",
                    "supported": true,
                    "cvcPolicy": "required",
                    "expiryDatePolicy": "required",
                    "enableLuhnCheck": true,
                    "showSocialSecurityNumber": false
                }
            ]
        }
        """

        let response = try JSONDecoder().decode(BinLookupResponse.self, from: XCTUnwrap(json.data(using: .utf8)))

        XCTAssertFalse(response.isCreatedLocally)
        XCTAssertEqual(response.brands?.map(\.brand), [.visa])
        XCTAssertEqual(response.brands?.map(\.isReliable), [true])
    }

}
