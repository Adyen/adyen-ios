//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Represents a token that is sent with a setup request.
internal struct PaymentRequestToken: Encodable {
    
    // MARK: - SDK Information
    
    /// The version of the token data representation.
    internal var tokenVersion = "1.0"
    
    /// The Checkout SDK version.
    internal var sdkVersion = Adyen.sdkVersion
    
    /// The API version to use.
    internal var apiVersion = "4"
    
    /// The integration type used to integrate the SDK.
    internal var integrationType = IntegrationType.custom
    
    // MARK: - Device Information
    
    /// A string identifying the platform.
    internal var platformIdentifier = "ios"
    
    /// The version of the device's system.
    internal var systemVersion = UIDevice.current.systemVersion
    
    /// The identifier of the device's locale.
    internal var localeIdentifier = NSLocale.current.identifier
    
    /// A string identifying the device.
    internal var deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    /// The device's model.
    internal var deviceModel = UIDevice.current.modelIdentifier
    
    // MARK: - Encoding
    
    /// An encoded representation of the token.
    internal var encoded: String {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(self)
        
        return data?.base64EncodedString() ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case tokenVersion = "deviceFingerprintVersion"
        case sdkVersion
        case apiVersion
        case integrationType = "integration"
        case platformIdentifier = "platform"
        case systemVersion = "osVersion"
        case localeIdentifier = "locale"
        case deviceIdentifier
        case deviceModel
    }
    
}

// MARK: - PaymentRequestToken.IntegrationType

internal extension PaymentRequestToken {
    
    /// The type of integration used to integrate the SDK.
    internal enum IntegrationType: String, Encodable {
        
        /// Indicates a Quick Integration.
        case quick
        
        /// Indicates a Custom Integration.
        case custom
        
    }
    
}
