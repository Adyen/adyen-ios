//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension AdyenAnalytics {
    
    /// Represents an event in the analytics scheme that can occur 
    /// many times during the checkout flow, such as input field focus/unfocus etc.
    internal struct Event: AdyenAnalyticsCommonFields {
        
        internal var commonFields: AdyenAnalytics.CommonFields
        
        internal var type: EventType
        
        internal var target: String
        
        internal var isStoredPaymentMethod: Bool
        
        internal var brand: String
        
        internal var validationErrorCode: String
        
        internal var validationErrorMessage: String
    }
    
    internal enum EventType: String, Encodable {
        case selected = "Selected"
        case focus = "Focus"
        case unfocus = "Unfocus"
    }
}
