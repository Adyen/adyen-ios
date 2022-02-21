//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
extension URL: AdyenCompatible {}

/// :nodoc:
extension AdyenScope where Base == URL {
    
    /// :nodoc:
    public var queryParameters: [String: String] {
        let components = URLComponents(url: base, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []

        return Dictionary(uniqueKeysWithValues: queryItems.map {
            ($0.name, $0.value?.removingPercentEncoding ?? "")
        })
    }

    /// :nodoc:
    public var isHttp: Bool {
        base.scheme == "http" || base.scheme == "https"
    }
}
