//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A stored Bancontact account.
public struct StoredBCMCPaymentMethod: StoredPaymentMethod {
    
    private let storedCardPaymentMethod: StoredCardPaymentMethod
    
    /// :nodoc:
    public let type: String = PaymentMethodType.bcmc.rawValue
    
    /// :nodoc:
    public var identifier: String { storedCardPaymentMethod.identifier }
    
    /// :nodoc:
    public var name: String { storedCardPaymentMethod.name }
    
    /// :nodoc:
    public var displayInformation: DisplayInformation {
        storedCardPaymentMethod.displayInformation
    }
    
    /// Display information for the payment method, adapted for displaying in a list.
    ///
    /// - Parameters:
    ///   - parameters: The localization parameters.
    public func localizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        storedCardPaymentMethod.localizedDisplayInformation(using: parameters)
    }
    
    /// :nodoc:
    public var supportedShopperInteractions: [ShopperInteraction] {
        storedCardPaymentMethod.supportedShopperInteractions
    }
    
    /// The brand of the stored card, in this case its a constant `"bcmc"`.
    public let brand: String = PaymentMethodType.bcmc.rawValue
    
    /// The last four digits of the card number.
    public var lastFour: String { storedCardPaymentMethod.lastFour }
    
    /// The month the card expires.
    public var expiryMonth: String { storedCardPaymentMethod.expiryMonth }
    
    /// The year the card expires.
    public var expiryYear: String { storedCardPaymentMethod.expiryYear }
    
    /// The name of the cardholder.
    public var holderName: String? { storedCardPaymentMethod.holderName }
    
    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    // MARK: - Decoding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        self.storedCardPaymentMethod = try StoredCardPaymentMethod(from: decoder)
    }
    
}
