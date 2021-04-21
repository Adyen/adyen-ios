//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
extension URLSession: AdyenCompatible {}

/// :nodoc:
public extension AdyenScope where Base: URLSession {

    /// :nodoc:
    func dataTask(with url: URL, completion: @escaping ((Result<Data, Error>) -> Void)) -> URLSessionDataTask {
        base.dataTask(with: url, completionHandler: { data, response, error in
            self.handle(data: data, response: response, error: error, completion: completion)
        })
    }

    /// :nodoc:
    func dataTask(with urlRequest: URLRequest, completion: @escaping ((Result<Data, Error>) -> Void)) -> URLSessionDataTask {
        base.dataTask(with: urlRequest, completionHandler: { data, response, error in
            self.handle(data: data, response: response, error: error, completion: completion)
        })
    }

    /// :nodoc:
    private func handle(data: Data?, response: URLResponse?, error: Error?, completion: @escaping ((Result<Data, Error>) -> Void)) {
        let httpResponse = response as? HTTPURLResponse
        if let headers = httpResponse?.allHeaderFields,
           let path = response?.url?.path {
            adyenPrint("---- Response Headers (/\(path)) ----")
            adyenPrint(headers)
        }

        let statusCode = httpResponse?.statusCode

        if let error = error {
            completion(.failure(error))
        } else if let statusCode = statusCode, statusCode != 200,
                  let data = data {
            adyenPrint("---- Response (/\(String(describing: response?.url?.path))) ----")
            printAsJSON(data)
            let fallbackError = APIError(status: statusCode,
                                         errorCode: "\(statusCode)",
                                         errorMessage: "Http \(statusCode) error",
                                         type: .urlError)
            let apiError: APIError? = try? Coder.decode(data)
            completion(.failure(apiError ?? fallbackError))
        } else if let data = data {
            completion(.success(data))
        } else {
            fatalError("Invalid response.")
        }
    }
}
