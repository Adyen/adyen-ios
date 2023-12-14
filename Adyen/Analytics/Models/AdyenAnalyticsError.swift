//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension AdyenAnalytics {
    
    /// Represents an error in the analytics scheme that indicates the flow was interrupted due to an error in the SDK.
    internal struct Error: AdyenAnalyticsCommonFields {
        
        internal var commonFields: AdyenAnalytics.CommonFields
        
        internal var type: ErrorType
        
        internal var code: String
        
        internal var message: String
    }
    
    internal enum ErrorType: String, Encodable {
        case network = "Network"
        case implementation = "Implementation"
        case `internal` = "Internal"
        case api = "ApiError"
        case sdk = "SdkError"
        case thirdParty = "ThirdParty"
        case generic = "Generic"
    }
}
