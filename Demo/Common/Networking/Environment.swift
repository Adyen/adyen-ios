//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal enum DemoServerEnvironment: String, APIEnvironment, CaseIterable {
    
    case beta, test, local
    
    internal var baseURL: URL {
        switch self {
        case .beta:
            return URL(string: "https://checkout-beta.adyen.com/checkout/v\(version)")!
        case .test:
            return URL(string: "https://checkout-test.adyen.com/v\(version)")!
        case .local:
            return URL(string: "http://localhost:8080/checkout/v\(version)")!
        }
    }

    internal var version: Int { ConfigurationConstants.current.apiVersion }

    internal var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "X-API-Key": ConfigurationConstants.demoServerAPIKey
        ]
    }

    /// :nodoc:
    internal var queryParameters: [URLQueryItem] { [] }
}
