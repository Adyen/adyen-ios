//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A stored PayPal account.
public struct StoredPayPalPaymentMethod: StoredPaymentMethod {
    
    /// :nodoc:
    public let type: String
    
    /// :nodoc:
    public let identifier: String
    
    /// :nodoc:
    public let name: String
    
    /// :nodoc:
    public let supportedShopperInteractions: [ShopperInteraction]
    
    /// :nodoc:
    public var displayInformation: DisplayInformation {
        return DisplayInformation(title: emailAddress, subtitle: nil, logoName: type)
    }
    
    /// The email address of the PayPal account.
    public let emailAddress: String
    
    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        return builder.build(paymentMethod: self)
    }
    
    // MARK: - Decoding
    
    private enum CodingKeys: String, CodingKey {
        case type
        case identifier = "id"
        case name
        case emailAddress = "shopperEmail"
        case supportedShopperInteractions
    }
    
}
