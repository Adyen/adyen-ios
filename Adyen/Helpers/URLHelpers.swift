//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public extension URL {

    @available(*, deprecated, renamed: "adyen.queryParameters", message: "Use .adyen.queryParameters instead")
    var queryParameters: [String: String] {
        adyen.queryParameters
    }

    @available(*, deprecated, renamed: "adyen.isHttp", message: "Use .adyen.isHttp instead")
    var isHttp: Bool {
        adyen.isHttp
    }

}

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
