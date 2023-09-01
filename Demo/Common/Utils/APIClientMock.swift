//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking

typealias MockedResult = Result<Response, Error>

final class APIClientMock: APIClientProtocol {

    var mockedResults: [MockedResult] = []
    var onExecute: ((any Request) -> Void)?

    private(set) var counter: Int = 0

    func perform<R>(_ request: R, completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void) where R: Request {
        counter += 1
        let nextResult = self.mockedResults.removeFirst()
        DispatchQueue.main.async {
            self.onExecute?(request)
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
