//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

struct DemoAPIContext: AnyAPIContext {
    
    init(environment: AnyAPIEnvironment = ConfigurationConstants.demoServerEnvironment) {
        self.environment = environment
    }
    
    let environment: AnyAPIEnvironment
    
    let headers: [String: String] = [
        "Content-Type": "application/json",
        "X-API-Key": ConfigurationConstants.demoServerAPIKey
    ]
    
    let queryParameters: [URLQueryItem] = []
    
}

enum DemoCheckoutAPIEnvironment: String, AnyAPIEnvironment, CaseIterable {
    
    case beta, test, local
    
    var baseURL: URL {
        switch self {
        case .beta:
            return URL(string: "https://checkout-beta.adyen.com/checkout/v\(version)")!
        case .test:
            return URL(string: "https://checkout-test.adyen.com/v\(version)")!
        case .local:
            return URL(string: "http://localhost:8080/checkout/v\(version)")!
        }
    }

    var version: Int { ConfigurationConstants.current.apiVersion }
    
}

enum DemoClassicAPIEnvironment: String, AnyAPIEnvironment, CaseIterable {
    
    case beta, test, local
    
    var baseURL: URL {
        switch self {
        case .beta:
            return URL(string: "https://pal-beta.adyen.com/pal/servlet/")!
        case .test:
            return URL(string: "https://pal-test.adyen.com/pal/servlet/")!
        case .local:
            return URL(string: "http://localhost:8080/pal/servlet/")!
        }
    }
    
}
