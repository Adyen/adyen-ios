//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct AdyenAnalytics {
  
    internal struct CommonFields: Encodable {
        
        internal var timestamp = ISO8601DateFormatter().string(from: Date())
        
        internal var component: String
        
        internal var metadata: [String: String] = [:]
    }
    
}

internal protocol AdyenAnalyticsCommonFields: Encodable {
    var commonFields: AdyenAnalytics.CommonFields { get }
}

