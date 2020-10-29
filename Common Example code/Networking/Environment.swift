//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal enum DemoServerEnvironment: APIEnvironment {
    
    case beta, test, directTest
    
    internal var baseURL: URL {
        switch self {
        case .beta:
            return URL(string: "https://checkoutshopper-beta.adyen.com/checkoutshopper/demoserver/")!
        case .test:
            return URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/")!
        case .directTest:
            return URL(string: "https://checkout-test.adyen.com/v64")!
        }
    }
    
    internal var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        switch self {
        case .directTest:
            headers["X-API-Key"] = Configuration.demoServerAPIKey
        default:
            headers["x-demo-server-api-key"] = Configuration.demoServerAPIKey
        }

        return headers
    }
    
    /// :nodoc:
    internal var queryParameters: [URLQueryItem] {
        return [URLQueryItem(name: "token", value: Configuration.clientKey)]
    }
}
