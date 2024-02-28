//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// Represents an info event  in the analytics scheme that can occur
/// multiple times during the checkout flow, such as input field focus/unfocus etc.
public struct AnalyticsEventInfo: AnalyticsEvent {
    public var component: String
    
    public var type: InfoType
    
    public var target: AnalyticsEventTarget?
    
    public var isStoredPaymentMethod: Bool?
    
    public var brand: String?
    
    public var validationErrorCode: String?
    
    public var validationErrorMessage: String?
    
    public enum InfoType: String, Encodable {
        case selected = "Selected"
        case focus = "Focus"
        case unfocus = "Unfocus"
        case validationError = "ValidationError"
        case rendered = "Rendered"
    }
}
