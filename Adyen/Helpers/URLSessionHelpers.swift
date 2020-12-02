//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
extension URLSession: AdyenCompatible {}

public extension AdyenScope where Base: URLSession {
    func dataTask(with url: URL, completion: @escaping ((Result<Data, Error>) -> Void)) -> URLSessionDataTask {
        return base.dataTask(with: url, completionHandler: { data, response, error in
            self.handle(data: data, response: response, error: error, completion: completion)
        })
    }
    
    func dataTask(with urlRequest: URLRequest, completion: @escaping ((Result<Data, Error>) -> Void)) -> URLSessionDataTask {
        return base.dataTask(with: urlRequest, completionHandler: { data, response, error in
            self.handle(data: data, response: response, error: error, completion: completion)
        })
    }

    private func handle(data: Data?, response: URLResponse?, error: Error?, completion: @escaping ((Result<Data, Error>) -> Void)) {
        let httpResponse = response as? HTTPURLResponse
        if let headers = httpResponse?.allHeaderFields,
           let path = response?.url?.path {
            adyenPrint("---- Response Headers (/\(path)) ----")
            adyenPrint(headers)
        }
        if let statusCode = httpResponse?.statusCode, statusCode != 200 {
            let error = APIError(status: statusCode,
                                 errorCode: "\(statusCode)",
                                 errorMessage: "Http \(statusCode) error",
                                 type: .urlError)
            completion(.failure(error))
        } else if let error = error {
            completion(.failure(error))
        } else if let data = data {
            completion(.success(data))
        } else {
            fatalError("Invalid response.")
        }
    }
}
