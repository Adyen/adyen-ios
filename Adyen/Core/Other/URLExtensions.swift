//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension URL {
    func queryParameters() -> [String: String]? {
        var parameters = [String: String]()
        
        let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)
        if let items = urlComponents?.queryItems {
            for item in items {
                parameters[item.name] = item.value ?? ""
            }
        }
        return parameters
    }
}
