//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardBrandProviderTests: XCTestCase {

    var publicKeyProvider: PublicKeyProviderMock!
    var apiClientMock: APIClientMock!
    var sut: BinInfoProvider!

    override func setUp() {
        publicKeyProvider = PublicKeyProviderMock()
        apiClientMock = APIClientMock()
        sut = BinInfoProvider(apiClient: apiClientMock,
                              publicKeyProvider: publicKeyProvider,
                              minBinLength: 11,
                              binLookupType: .card)
    }

    override func tearDown() {
        publicKeyProvider = nil
        apiClientMock = nil
        sut = nil
    }

    func testLocalCardTypeFetch() {
        publicKeyProvider.onFetch = {
            XCTFail("Should not call APIClient")
            $0(.success(Dummy.publicKey))
        }
        apiClientMock.onExecute = {
            XCTFail("Should not call APIClient")
        }

        sut.provide(for: "56", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.type), [.maestro])
        }
    }

    func testRemoteCardTypeFetch() {
        publicKeyProvider.onFetch = { $0(.success(Dummy.publicKey)) }
        let mockedBrands = [CardBrand(type: .solo)]
        apiClientMock.mockedResults = [.success(BinLookupResponse(brands: mockedBrands))]

        sut.provide(for: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.type), [.solo])
        }
    }

    func testLocalCardTypeFetchWhenPublicKeyFailure() {
        publicKeyProvider.onFetch = { $0(.failure(Dummy.error)) }
        apiClientMock.onExecute = { XCTFail("Should not call APIClient") }
        sut.provide(for: "56", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.type), [.maestro])
        }
    }

    func testRemoteCardTypeFetchWhenPublicKeyFailure() {
        publicKeyProvider.onFetch = { $0(.failure(Dummy.error)) }
        apiClientMock.onExecute = { XCTFail("Should not call APIClient") }

        sut.provide(for: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.type), [.maestro])
        }
    }

}
