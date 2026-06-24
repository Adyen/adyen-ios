//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardBrandProviderTests: XCTestCase {

    var apiClientMock: APIClientMock!
    var sut: BinInfoProvider!

    override func setUp() {
        apiClientMock = APIClientMock()
        sut = BinInfoProvider(
            apiClient: apiClientMock,
            adyenContext: Dummy.context,
            minBinLength: 11,
            binLookupType: .card
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

        sut.provide(for: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.brand), [.solo])
        }
    }

    func testRemoteCardBrandFetchWithAPIFailure() {
        apiClientMock.mockedResults = [.failure(Dummy.error)]

        sut.provide(for: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.brand), [.maestro])
        }
    }

}
