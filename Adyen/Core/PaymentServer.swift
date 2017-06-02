//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class PaymentServer {
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    func post(url: URL, info: [String: Any], completion: @escaping (_ info: [String: Any]?, _ error: Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: info, options: [])
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        
        _ = session.dataTask(with: request) { data, response, error in
            guard
                let rawData = data,
                let json = try? JSONSerialization.jsonObject(with: rawData, options: []) as? [String: Any]
            else {
                if let error = error {
                    completion(nil, .networkError(error))
                } else {
                    completion(nil, .unexpectedData)
                }
                return
            }
            
            completion(json, nil)
            
        }.resume()
    }
}
