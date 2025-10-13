//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public struct SDKData: Codable {
    
    internal struct Analytics: Codable {
        internal let checkoutAttemptId: String
    }
    
    public struct Authentication: Codable {
        internal let threeDS2SdkVersion: String
        
        public init(threeDS2SdkVersion: String) {
            self.threeDS2SdkVersion = threeDS2SdkVersion
        }
    }
    
    internal let analytics: Analytics
    internal private(set) var authentication: Authentication?
    private let supportNativeRedirect: Bool = true
    private let schemaVersion: String = SchemaVersions.v1_0
    private let timestamp = Int(Date().timeIntervalSince1970 * 1000)
    
    internal var encodedValue: String? {
        try? AdyenCoder.encodeBase64(self)
    }
    
    internal init(
        checkoutAttemptId: String,
        authenticationProvider: SDKDataAuthenticationProvider? = nil
    ) {
        self.analytics = .init(checkoutAttemptId: checkoutAttemptId)
        self.authentication = authenticationProvider?.authentication
    }
    
    private enum CodingKeys: String, CodingKey {
        case analytics
        case authentication
        case supportNativeRedirect
        case schemaVersion
        case timestamp = "createdAt"
    }
    
    private enum SchemaVersions {
        // swiftlint:disable:next identifier_name
        internal static let v1_0 = "1.0"
    }
}

@_spi(AdyenInternal)
public protocol SDKDataAuthenticationProvider {
    var authentication: SDKData.Authentication { get }
}
