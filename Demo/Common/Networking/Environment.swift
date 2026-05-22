//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal struct DemoAPIContext: AnyAPIContext {
    
    internal init(environment: AnyAPIEnvironment = ConfigurationConstants.demoServerEnvironment) {
        self.environment = environment
    }
    
    internal let environment: AnyAPIEnvironment
    
    internal let headers: [String: String] = [
        "Content-Type": "application/json",
        "X-API-Key": ConfigurationConstants.adyenServerKey
    ]
    
    internal let queryParameters: [URLQueryItem] = []
    
}

internal enum DemoCheckoutAPIEnvironment: String, AnyAPIEnvironment, CaseIterable {
    
    case test, local

    private enum Constants {
        static let localCheckoutAPIVersion = 72
    }
    
    internal var baseURL: URL {
        switch self {
        case .test:
            return URL(string: "https://\(ConfigurationConstants.serverUrl)")!
        case .local:
            return URL(string: "http://localhost:8080/checkout/v\(version)")!
        }
    }
    
    internal var version: Int {
        switch self {
        case .test:
            // The test Checkout API version is taken from MERCHANT_SERVER_HOST in Demo/Secrets*.xcconfig.
            return checkoutAPIVersion(from: ConfigurationConstants.serverUrl) ?? Constants.localCheckoutAPIVersion
        case .local:
            return Constants.localCheckoutAPIVersion
        }
    }

    private func checkoutAPIVersion(from serverURL: String) -> Int? {
        guard let match = serverURL.range(of: #"/checkout/v(\d+)"#, options: .regularExpression) else {
            return nil
        }

        let versionComponent = serverURL[match].split(separator: "v").last
        return versionComponent.flatMap { Int($0) }
    }
    
}
