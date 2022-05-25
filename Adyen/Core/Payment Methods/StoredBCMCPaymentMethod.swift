//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A stored Bancontact account.
public struct StoredBCMCPaymentMethod: StoredPaymentMethod {
    
    private var storedCardPaymentMethod: StoredCardPaymentMethod
    
    public let type: PaymentMethodType = .bcmc
    
    public var name: String { storedCardPaymentMethod.name }
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation? {
        get { storedCardPaymentMethod.merchantProvidedDisplayInformation }
        set { storedCardPaymentMethod.merchantProvidedDisplayInformation = newValue }
    }

    public var identifier: String { storedCardPaymentMethod.identifier }

    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        storedCardPaymentMethod.displayInformation(using: parameters)
    }
    
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
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    // MARK: - Decoding
    
    public init(from decoder: Decoder) throws {
        self.storedCardPaymentMethod = try StoredCardPaymentMethod(from: decoder)
    }
    
}
