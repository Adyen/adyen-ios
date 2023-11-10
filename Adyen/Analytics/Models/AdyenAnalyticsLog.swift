//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension AdyenAnalytics {
    
    /// A log in the analytics scheme represents important checkpoints such as the pay button press, 3ds challenge etc.
    struct Log: AdyenAnalyticsCommonFields {
        
        internal var commonFields: AdyenAnalytics.CommonFields
        
        internal var type: LogType
        
        internal var subType: LogSubType
        
        internal var target: String
        
        internal var message: String
    }
    
    enum LogType: String, Encodable {
        case action = "Action"
        case submit = "Submit"
    }
    
    enum LogSubType: String, Encodable {
        case threeDS2 = "ThreeDS2"
        case redirect = "Redirect"
        case voucher = "Voucher"
        case await = "Await"
        case qrCode = "QrCode"
        case bankTransfer = "BankTransfer"
        case sdk = "Sdk"
    }
}
