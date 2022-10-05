//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An ACH Direct Debit payment method.
public struct ACHDirectDebitPaymentMethod: PaymentMethod {
    
    public let type: PaymentMethodType

    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    @_spi(AdyenInternal)
    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name.uppercased(), subtitle: nil, logoName: type.rawValue)
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
    
}

/// A stored ACH Direct Debit Account
public struct StoredACHDirectDebitPaymentMethod: StoredPaymentMethod {
    
    public let type: PaymentMethodType

    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    public let identifier: String

    public let supportedShopperInteractions: [ShopperInteraction]
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    @_spi(AdyenInternal)
    public func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let bankAccountLastFour = String(bankAccountNumber.suffix(4))
        
        return DisplayInformation(title: String.Adyen.securedString + bankAccountLastFour,
                                  subtitle: localizedString(.achBankAccountTitle, parameters),
                                  logoName: type.rawValue)
    }
    
    /// Number of the stored account
    public let bankAccountNumber: String
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case identifier = "id"
        case supportedShopperInteractions
        case bankAccountNumber
    }
}
