//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension URL {
    var queryParameters: [String: String] { // swiftlint:disable:this explicit_acl
        let components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        let queryItems = components?.queryItems ?? []
        
        return Dictionary(uniqueKeysWithValues: queryItems.map {
            ($0.name, $0.value ?? "")
        })
    }
}
