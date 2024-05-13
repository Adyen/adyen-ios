//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// A log in the analytics scheme represents important checkpoints such as the pay button press, 3ds challenge etc.
public struct AnalyticsEventLog: AnalyticsEvent {
    
    public var id: String = UUID().uuidString
    
    public var timestamp = Int(Date().timeIntervalSince1970)
    
    public var component: String
    
    public var type: LogType
    
    public var subType: LogSubType?
    
    public var target: AnalyticsEventTarget?
    
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
        case fingerprintSent = "FingerprintDataSentMobile"
        case fingerprintComplete = "FingerprintCompleted"
        case challengeDataSent = "ChallengeDataSentMobile"
        case challengeDisplayed = "ChallengeDisplayed"
        case challengeComplete = "ChallengeCompleted"
    }
    
    public init(component: String, type: LogType, subType: LogSubType? = nil) {
        self.component = component
        self.type = type
        self.subType = subType
    }
}
