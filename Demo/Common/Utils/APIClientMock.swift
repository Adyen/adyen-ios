//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking

internal typealias MockedResult = Result<Response, Error>

internal final class APIClientMock: APIClientProtocol {

    internal var mockedResults: [MockedResult] = []
    internal var onExecute: (() -> Void)?

    internal private(set) var counter: Int = 0

    internal func perform<R>(_ request: R, completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void) where R: Request {
        counter += 1
        let nextResult = self.mockedResults.removeFirst()
        DispatchQueue.main.async {
            self.onExecute?()
            switch nextResult {
            case let .success(response):
                guard let response = response as? R.ResponseType else { return }
                completionHandler(.success(response))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

}
