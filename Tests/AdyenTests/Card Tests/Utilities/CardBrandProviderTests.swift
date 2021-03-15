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
        let parameters = CardBrandProviderParameters(bin: "56", supportedTypes: [.masterCard, .visa, .maestro])
        sut.provide(for: parameters) { result in
            XCTAssertEqual(result.map(\.type), [.maestro])
        }
    }

    func testRemoteCardTypeFetch() {
        cardPublicKeyProvider.onFetch = { $0(.success(Dummy.dummyPublicKey)) }
        let mockedBrands = [CardBrand(type: .solo)]
        apiClientMock.mockedResults = [.success(BinLookupResponse(brands: mockedBrands))]
        let parameters = CardBrandProviderParameters(bin: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro])
        sut.provide(for: parameters) { result in
            XCTAssertEqual(result.map(\.type), [.solo])
        }
    }

    func testLocalCardTypeFetchWhenPublicKeyFailure() {
        cardPublicKeyProvider.onFetch = { $0(.failure(Dummy.dummyError)) }
        apiClientMock.onExecute = { XCTFail("Shoul not call APIClient") }
        let parameters = CardBrandProviderParameters(bin: "56", supportedTypes: [.masterCard, .visa, .maestro])
        sut.provide(for: parameters) { result in
            XCTAssertEqual(result.map(\.type), [.maestro])
        }
    }

    func testRemoteCardTypeFetchWhenPublicKeyFailure() {
        cardPublicKeyProvider.onFetch = { $0(.failure(Dummy.dummyError)) }
        apiClientMock.onExecute = { XCTFail("Shoul not call APIClient") }
        let parameters = CardBrandProviderParameters(bin: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro])
        sut.provide(for: parameters) { result in
            XCTAssertEqual(result.map(\.type), [.maestro])
        }
    }

}
