//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// So that any `URL` instance will inherit the `adyen` scope.
/// :nodoc:
extension URL: AdyenCompatible {}

/// Adds helper functionality to any `URL` instance through the `adyen` property.
/// :nodoc:
public extension AdyenScope where Base == URL {

    /// An array of of query parameters
    var queryParameters: [String: String] {
        let components = URLComponents(url: base, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        return Dictionary(uniqueKeysWithValues: queryItems.map {
            ($0.name, $0.value?.removingPercentEncoding ?? "")
        })
    }

    /// A Boolean value indicating the URL is  http
    var isHttp: Bool {
        base.scheme == "http" || base.scheme == "https"
    }

}
