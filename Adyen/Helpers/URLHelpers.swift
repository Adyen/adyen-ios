//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public extension URL {
    var queryParameters: [String: String] {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        return Dictionary(uniqueKeysWithValues: queryItems.map {
            ($0.name, $0.value?.removingPercentEncoding ?? "")
        })
    }
    
    var isHttp: Bool {
        scheme == "http" || scheme == "https"
    }
}
