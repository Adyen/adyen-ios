//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Helper for reading configuration values from .xcconfig locally or environment variables on CI
extension ConfigurationConstants {

    enum SecretKey: String {
        case clientKey = "ADYEN_CLIENT_KEY"
        case demoServerAPIKey = "ADYEN_DEMO_SERVER_API_KEY"
        case merchantAccount = "ADYEN_MERCHANT_ACCOUNT"
        case appleTeamIdentifier = "APPLE_TEAM_IDENTIFIER"
        case applePayMerchantIdentifier = "APPLE_PAY_MERCHANT_IDENTIFIER"
    }
    
    /// Get configuration value from .xcconfig or environment variables
    /// - Parameters:
    ///   - key: The configuration key
    ///   - defaultValue: Optional default value if key is not found
    /// - Returns: The configuration value or default value
    static func value(for key: SecretKey, defaultValue: String = "") -> String {
        // First try to get from environment variables for CI
        if let envValue = ProcessInfo.processInfo.environment[key.rawValue], !envValue.isEmpty {
            return envValue
        }
        
        // Then fallback to .xcconfig
        if let bundleValue = Bundle.main.infoDictionary?[key.rawValue] as? String, !bundleValue.isEmpty {
            return bundleValue
        }

        return defaultValue
    }
}
