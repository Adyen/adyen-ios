//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension URL: AdyenCompatible {}

package extension AdyenScope where Base == URL {
    
    var queryParameters: [String: String] {
        let components = URLComponents(url: base, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []

        return Dictionary(uniqueKeysWithValues: queryItems.map {
            ($0.name, $0.value?.removingPercentEncoding ?? "")
        })
    }

    var isHttp: Bool {
        base.scheme == "http" || base.scheme == "https"
    }
}
