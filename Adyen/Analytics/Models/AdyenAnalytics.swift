//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public final class AdyenAnalytics {
    
    @_spi(AdyenInternal)
    /// Needed to be able to determine if using session
    public static var sessionId: String?
  
    internal struct CommonFields: Encodable {
        
        internal var timestamp = ISO8601DateFormatter().string(from: Date())
        
        internal var component: String
        
        internal var metadata: [String: String] = [:]
    }
    
}

internal protocol AdyenAnalyticsCommonFields: Encodable {
    var commonFields: AdyenAnalytics.CommonFields { get }
}

//@_spi(AdyenInternal)
//public protocol AdyenAnalyticEvent {
//    var commonFields: AdyenAnalytics.CommonFields { get }
//}
