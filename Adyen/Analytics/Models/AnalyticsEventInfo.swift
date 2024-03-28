//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// Represents an info event  in the analytics scheme that can occur
/// multiple times during the checkout flow, such as input field focus/unfocus etc.
public struct AnalyticsEventInfo: AnalyticsEvent {
    
    public var id: String = UUID().uuidString
    
    public var timestamp = Int(Date().timeIntervalSince1970)
    
    public var component: String
    
    public var type: InfoType
    
    public var target: AnalyticsEventTarget?
    
    public var isStoredPaymentMethod: Bool?
    
    public var brand: String?
    
    public var issuer: String?
    
    public var validationErrorCode: String?
    
    public var validationErrorMessage: String?
    
    public enum InfoType: String, Encodable {
        case selected = "Selected"
        case focus = "Focus"
        case unfocus = "Unfocus"
        case validationError = "ValidationError"
        case rendered = "Rendered"
        case input = "Input"
    }
    
    public init(component: String, type: InfoType) {
        self.component = component
        self.type = type
    }
}
