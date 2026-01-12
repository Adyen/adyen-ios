//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package struct SDKData: Codable {
    
    internal struct Analytics: Codable {
        internal let checkoutAttemptId: String
    }
    
    package struct Authentication: Codable {
        internal let threeDS2SdkVersion: String
        
        package init(threeDS2SdkVersion: String) {
            self.threeDS2SdkVersion = threeDS2SdkVersion
        }
    }
    
    internal let analytics: Analytics
    internal private(set) var authentication: Authentication?
    internal let schemaVersion: Int = SchemaVersions.v1
    private let supportNativeRedirect: Bool = true
    private let timestamp = Int(Date().timeIntervalSince1970 * 1000)
    
    package var encodedValue: String? {
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
        internal static let v1 = 1
    }
}

package protocol SDKDataAuthenticationProvider {
    var authentication: SDKData.Authentication { get }
}
