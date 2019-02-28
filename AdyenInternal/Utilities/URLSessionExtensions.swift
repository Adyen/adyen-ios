//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension URLSession {
    func dataTask(with url: URL, completion: @escaping ((URLSessionResult) -> Void)) -> URLSessionDataTask {
        return dataTask(with: url, completionHandler: { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            } else {
                fatalError("Invalid response.")
            }
        })
    }
    
    func dataTask(with urlRequest: URLRequest, completion: @escaping ((URLSessionResult) -> Void)) -> URLSessionDataTask {
        return dataTask(with: urlRequest, completionHandler: { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            } else {
                fatalError("Invalid response.")
            }
        })
    }
    
}

public enum URLSessionResult {
    case success(Data)
    case failure(Error)
}
