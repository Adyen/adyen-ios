//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardBrandProviderTests: XCTestCase {

    var cardPublicKeyProvider: CardPublicKeyProviderMock!
    var apiClientMock: APIClientMock!
    var sut: CardBrandProvider!

    override func setUp() {
        cardPublicKeyProvider = CardPublicKeyProviderMock()
        apiClientMock = APIClientMock()
        sut = CardBrandProvider(cardPublicKeyProvider: cardPublicKeyProvider, apiClient: apiClientMock)
    }

    override func tearDown() {
        cardPublicKeyProvider = nil
        apiClientMock = nil
        sut = nil
    }

    func testLocalCardTypeFetch() {
        cardPublicKeyProvider.onFetch = {
            XCTFail("Shoul not call APIClient")
            $0(.success(Dummy.dummyPublicKey))
        }
        apiClientMock.onExecute = {
            XCTFail("Shoul not call APIClient")
        }
        sut.provide(for: "56", supported: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.map { $0.type }, [.maestro])
        }
    }

    func testRemoteCardTypeFetch() {
        cardPublicKeyProvider.onFetch = { $0(.success(Dummy.dummyPublicKey)) }
        let mockedBrands = [CardBrand(type: .solo)]
        apiClientMock.mockedResults = [.success(BinLookupResponse(brands: mockedBrands))]
        sut.provide(for: "5656565656565656", supported: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.map { $0.type }, [.solo])
        }
    }

    func testLocalCardTypeFetchWhenPublicKeyFailure() {
        cardPublicKeyProvider.onFetch = { $0(.failure(Dummy.dummyError)) }
        apiClientMock.onExecute = { XCTFail("Shoul not call APIClient") }
        sut.provide(for: "56", supported: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.map { $0.type }, [.maestro])
        }
    }

    func testRemoteCardTypeFetchWhenPublicKeyFailure() {
        cardPublicKeyProvider.onFetch = { $0(.failure(Dummy.dummyError)) }
        apiClientMock.onExecute = { XCTFail("Shoul not call APIClient") }
        sut.provide(for: "5656565656565656", supported: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.map { $0.type }, [.maestro])
        }
    }

}
