//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
extension URL: AdyenCompatible {}

@_spi(AdyenInternal)
extension AdyenScope where Base == URL {
    
    public var queryParameters: [String: String] {
        let components = URLComponents(url: base, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []

        return Dictionary(uniqueKeysWithValues: queryItems.map {
            ($0.name, $0.value?.removingPercentEncoding ?? "")
        })
    }

    public var isHttp: Bool {
        base.scheme == "http" || base.scheme == "https"
    }
}
