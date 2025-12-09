//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Helper for reading configuration values from .xcconfig locally or environment variables on CI
internal extension ConfigurationConstants {
    
    enum SecretKey: String {
        case clientKey = "MERCHANT_CLIENT_KEY"
        case serverUrl = "MERCHANT_SERVER_HOST"
        case merchantAccount = "MERCHANT_ACCOUNT"
        case adyenServerKey = "ADYEN_SERVER_API_KEY"
        case appleTeamIdentifier = "APPLE_TEAM_IDENTIFIER"
        case applePayMerchantIdentifier = "APPLE_PAY_MERCHANT_IDENTIFIER"
    }
    
    static func secretValue(for key: SecretKey) -> String {
        guard let value = Bundle.main.infoDictionary?[key.rawValue] as? String, !value.isEmpty else {
            fatalError("\(key.rawValue) has to be provided via .xcconfig or environment variable and must not be empty")
        }
        return value
    }
}
