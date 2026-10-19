//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenNetworking
import XCTest

final class PerformAsyncTests: XCTestCase {

    // MARK: - Test Helpers

    private struct MockResponse: Response, Equatable {
        let value: String
    }

    private struct MockErrorResponse: ErrorResponse, Equatable {
        let errorMessage: String
    }

    private struct MockRequest: Request, Encodable {
        typealias ResponseType = MockResponse
        typealias ErrorResponseType = MockErrorResponse

        var path: String = "/test"
        var counter: UInt = 0
        var headers: [String: String] = [:]
        var queryParameters: [URLQueryItem] = []
        var method: HTTPMethod = .post

        private enum CodingKeys: CodingKey {}
    }

    private final class ThrowingAPIClientMock: AsyncAPIClientProtocol {
        var thrownError: Error?
        var responseBody: (any Response)?

        func perform<R: Request>(_ request: R) async throws -> HTTPResponse<R.ResponseType> {
            if let error = thrownError {
                throw error
            }
            guard let body = responseBody as? R.ResponseType else {
                fatalError("Response type mismatch")
            }
            return HTTPResponse(headers: [:], statusCode: 200, responseBody: body)
        }

        func perform<R: Request>(_ request: R) async throws -> HTTPResponse<R.ResponseType> where R.ResponseType == DownloadResponse {
            fatalError("Not supported")
        }
    }

    // MARK: - Tests

    func testPerformAsyncReturnsResponseBody() async throws {
        let mock = ThrowingAPIClientMock()
        mock.responseBody = MockResponse(value: "success")

        let result: MockResponse = try await mock.performAsync(MockRequest())

        XCTAssertEqual(result, MockResponse(value: "success"))
    }

    func testPerformAsyncUnwrapsHTTPErrorResponse() async {
        let mock = ThrowingAPIClientMock()
        let errorResponse = MockErrorResponse(errorMessage: "payment refused")
        let httpError = HTTPResponse(headers: [:], statusCode: 422, responseBody: errorResponse)
        mock.thrownError = httpError

        do {
            let _: MockResponse = try await mock.performAsync(MockRequest())
            XCTFail("Expected error to be thrown")
        } catch let error as MockErrorResponse {
            XCTAssertEqual(error.errorMessage, "payment refused")
        } catch {
            XCTFail("Expected MockErrorResponse, got \(type(of: error)): \(error)")
        }
    }

    func testPerformAsyncUnwrapsParsingError() async {
        let mock = ThrowingAPIClientMock()
        let decodingError = DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "test decoding error")
        )
        let parsingError = ParsingError(headers: [:], statusCode: 200, underlyingError: decodingError)
        mock.thrownError = parsingError

        do {
            let _: MockResponse = try await mock.performAsync(MockRequest())
            XCTFail("Expected error to be thrown")
        } catch let error as DecodingError {
            if case let .dataCorrupted(context) = error {
                XCTAssertEqual(context.debugDescription, "test decoding error")
            } else {
                XCTFail("Expected dataCorrupted, got \(error)")
            }
        } catch {
            XCTFail("Expected DecodingError, got \(type(of: error)): \(error)")
        }
    }

    func testPerformAsyncPassesThroughOtherErrors() async {
        let mock = ThrowingAPIClientMock()
        let networkError = URLError(.notConnectedToInternet)
        mock.thrownError = networkError

        do {
            let _: MockResponse = try await mock.performAsync(MockRequest())
            XCTFail("Expected error to be thrown")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet)
        } catch {
            XCTFail("Expected URLError, got \(type(of: error)): \(error)")
        }
    }
}
