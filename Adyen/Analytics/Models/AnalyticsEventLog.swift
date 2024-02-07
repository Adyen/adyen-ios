//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// A log in the analytics scheme represents important checkpoints such as the pay button press, 3ds challenge etc.
public struct AnalyticsEventLog: AnalyticsEvent {
    
    public var component: String
    
    public var type: LogType
    
    public var subType: LogSubType
    
    public var target: String
    
    public var message: String?
    
    public enum LogType: String, Encodable {
        case action = "Action"
        case submit = "Submit"
        case redirect = "Redirect"
        case threeDS2 = "ThreeDS2"
    }
    
    public enum LogSubType: String, Encodable {
        case threeDS2 = "ThreeDS2"
        case redirect = "Redirect"
        case voucher = "Voucher"
        case await = "Await"
        case qrCode = "QrCode"
        case bankTransfer = "BankTransfer"
        case sdk = "Sdk"
    }
}
