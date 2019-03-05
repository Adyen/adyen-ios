//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// Represents a token that is sent with a session request.
internal struct PaymentSessionToken: Encodable {
    
    // MARK: - SDK Information
    
    /// The version of the token data representation.
    internal var tokenVersion = "1.0"
    
    /// The Checkout SDK version.
    internal var sdkVersion = Adyen.sdkVersion
    
    /// The integration type used to integrate the SDK.
    internal var integrationType = IntegrationType.custom
    
    // MARK: - Device Information
    
    /// A string identifying the platform.
    internal var platformIdentifier = "ios"
    
    /// The version of the device's system.
    internal var systemVersion = UIDevice.current.systemVersion
    
    /// The identifier of the device's locale in the format aa_BB, where "aa" is language code and "BB" is region code.
    internal var localeIdentifier: String = {
        let languageCode = NSLocale.current.languageCode ?? ""
        let regionCode = NSLocale.current.regionCode ?? ""
        return "\(languageCode)_\(regionCode)"
    }()
    
    /// A string identifying the device.
    internal var deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    /// The device's model.
    internal var deviceModel = UIDevice.current.modelIdentifier
    
    /// The date the token was generated.
    internal var date = Date()
    
    private enum CodingKeys: String, CodingKey {
        case tokenVersion = "deviceFingerprintVersion"
        case sdkVersion
        case integrationType = "integration"
        case platformIdentifier = "platform"
        case systemVersion = "osVersion"
        case localeIdentifier = "locale"
        case deviceIdentifier
        case deviceModel
        case date = "generationTime"
    }
    
    // MARK: - Encoding
    
    /// Returns a base64 encoded representation of the token.
    internal var encoded: String {
        do {
            let data = try Coder.encode(self) as Data
            
            return data.base64EncodedString()
        } catch {
            fatalError("Unexpected error during token encoding: \(error)")
        }
    }
    
}

// MARK: - PaymentSessionToken.IntegrationType

internal extension PaymentSessionToken {
    /// The type of integration used to integrate the SDK.
    enum IntegrationType: String, Encodable {
        /// Indicates a Quick Integration.
        case quick
        
        /// Indicates a Custom Integration.
        case custom
        
    }
    
}
