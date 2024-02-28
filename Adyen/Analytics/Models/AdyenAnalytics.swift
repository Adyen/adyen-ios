//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// Used as a singleton to update the sessionId
public final class AnalyticsForSession {
    
    /// Needed to be able to determine if using session
    public static var sessionId: String?
    
    private init() { /* Private empty init */ }
}

@_spi(AdyenInternal)
/// A protocol that defines the events that can occur under Checkout Analytics.
public protocol AnalyticsEvent: Encodable {
    var timestamp: TimeInterval { get }
    
    var component: String { get }
    
    var id: String { get }
}

@_spi(AdyenInternal)
public extension AnalyticsEvent {
    
    var timestamp: TimeInterval {
        Date().timeIntervalSince1970
    }
    
    var id: String { UUID().uuidString }
}

@_spi(AdyenInternal)
public enum AnalyticsEventTarget: String, Encodable {
    case cardNumber = "card_number"
    case expiryDate = "expiry_date"
    case securityCode = "security_code"
    case holderName = "holder_name"
    case dualBrand
    case boletoSocialSecurityNumber = "social_security_number"
    case taxNumber = "tax_number"
    case addressStreet = "street"
    case addressHouseNumber = "house_number_or_name"
    case addressCity = "city"
    case addressPostalCode = "postal_code"
    case issuerList = "list"
    case listSearch = "list_search"
}
