//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking

internal typealias MockedResult = Result<Response, Error>

internal final class APIClientMock: APIClientProtocol {

    internal var mockedResults: [MockedResult] = []
    internal var onExecute: ((any Request) -> Void)?

    internal private(set) var counter: Int = 0

    internal func perform<R>(_ request: R, completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void) where R: Request {
        counter += 1
        let nextResult = self.mockedResults.removeFirst()
        DispatchQueue.main.async {
            self.onExecute?(request)
            switch nextResult {
            case let .success(response):
                guard let response = response as? R.ResponseType else {
                    fatalError("The provided Response '\(response.self)' does not match the ResponseType of the Request '\(R.ResponseType.self)'")
                }
                completionHandler(.success(response))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

}
