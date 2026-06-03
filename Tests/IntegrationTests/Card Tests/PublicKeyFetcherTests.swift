//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class PublicKeyFetcherTests: XCTestCase {

    func testFetchPublicKeySuccess() async throws {
        let mockApiClient = APIClientMock()
        mockApiClient.mockedResults = [.success(ClientKeyResponse(cardPublicKey: "test_public_key"))]

        let sut = PublicKeyFetcher()
        let publicKey = try await sut.fetchPublicKey(apiClient: mockApiClient, clientKey: "test_client_key")

        XCTAssertEqual(publicKey, "test_public_key")
        XCTAssertEqual(mockApiClient.counter, 1)
    }

    func testFetchPublicKeyDecodingErrorThrowsInvalidClientKey() async {
        let mockApiClient = APIClientMock()
        let decodingError = DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "test decoding error")
        )
        mockApiClient.mockedResults = [.failure(decodingError)]

        let sut = PublicKeyFetcher()

        do {
            _ = try await sut.fetchPublicKey(apiClient: mockApiClient, clientKey: "invalid_key")
            XCTFail("Expected invalidClientKey error")
        } catch let error as CheckoutError {
            XCTAssertEqual(error.code, .invalidClientKey)
            XCTAssertEqual(error.message, "The client key was not found on the selected environment.")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertEqual(mockApiClient.counter, 1)
    }

    func testFetchPublicKeyNetworkErrorIsRethrown() async {
        let mockApiClient = APIClientMock()
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        mockApiClient.mockedResults = [.failure(networkError)]

        let sut = PublicKeyFetcher()

        do {
            _ = try await sut.fetchPublicKey(apiClient: mockApiClient, clientKey: "test_client_key")
            XCTFail("Expected network error")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, NSURLErrorDomain)
            XCTAssertEqual(error.code, NSURLErrorNotConnectedToInternet)
        }

        XCTAssertEqual(mockApiClient.counter, 1)
    }
}

extension APIClientMock: APIClientKeyRequestProtocol {
    func perform(request: ClientKeyRequest, completionHandler: @escaping (Result<ClientKeyResponse, Error>) -> Void) {
        perform(request, completionHandler: completionHandler)
    }
}
