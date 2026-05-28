//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal final class DemoAPIClientMock: APIClientProtocol {

    internal var mockedResults: [Result<Response, Error>] = []

    internal func perform<R: Request>(_ request: R, completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void) {
        let nextResult = mockedResults.removeFirst()
        DispatchQueue.main.async {
            switch nextResult {
            case let .success(response):
                guard let response = response as? R.ResponseType else {
                    fatalError("""
                    The provided Response "\(response.self)" does not match \
                    the ResponseType of the Request "\(R.ResponseType.self)"
                    """)
                }
                completionHandler(.success(response))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
}
