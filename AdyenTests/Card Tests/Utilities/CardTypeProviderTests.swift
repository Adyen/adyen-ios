//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardTypeProviderTests: XCTestCase {

    var cardPublicKeyProvider: CardPublicKeyProviderMock!
    var apiClientMock: APIClientMock!
    var sut: CardTypeProvider!

    override func setUp() {
        cardPublicKeyProvider = CardPublicKeyProviderMock()
        apiClientMock = APIClientMock()
        sut = CardTypeProvider(cardPublicKeyProvider: cardPublicKeyProvider, apiClient: apiClientMock)
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
        sut.requestCardType(for: "56", supported: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result, [.maestro])
        }
    }

    func testRemoteCardTypeFetch() {
        cardPublicKeyProvider.onFetch = { $0(.success(Dummy.dummyPublicKey)) }
        apiClientMock.mockedResults = [.success(BinLookupResponse(detectedBrands: [.solo]))]
        sut.requestCardType(for: "5656565656565656", supported: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result, [.solo])
        }
    }

    func testLocalCardTypeFetchWhenPublicKeyFailure() {
        cardPublicKeyProvider.onFetch = { $0(.failure(Dummy.dummyError)) }
        apiClientMock.onExecute = { XCTFail("Shoul not call APIClient") }
        sut.requestCardType(for: "56", supported: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result, [.maestro])
        }
    }

    func testRemoteCardTypeFetchWhenPublicKeyFailure() {
        cardPublicKeyProvider.onFetch = { $0(.failure(Dummy.dummyError)) }
        apiClientMock.onExecute = { XCTFail("Shoul not call APIClient") }
        sut.requestCardType(for: "5656565656565656", supported: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result, [.maestro])
        }
    }

}
