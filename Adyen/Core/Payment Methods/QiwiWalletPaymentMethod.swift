//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A Qiwi Wallet payment method.
public struct QiwiWalletPaymentMethod: PaymentMethod {
    
    public let type: PaymentMethodType
    
    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?
    
    /// Qiwi Wallet details.
    public let phoneExtensions: [PhoneExtension]
    
    /// Initializes the Qiwi Wallet payment method.
    ///
    /// - Parameter type: The payment method type.
    /// - Parameter name: The payment method name.
    /// - Parameter phoneExtensions: The phone extensions supported.
    internal init(type: PaymentMethodType, name: String, phoneExtensions: [PhoneExtension] = []) {
        self.type = type
        self.name = name
        self.phoneExtensions = phoneExtensions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(PaymentMethodType.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        
        var phoneExtensions: [PhoneExtension]?
        if var detailsContainer = try? container.nestedUnkeyedContainer(forKey: .details) {
            while !detailsContainer.isAtEnd {
                let detailContainer = try detailsContainer.nestedContainer(keyedBy: CodingKeys.self)
                let detailKey = try detailContainer.decode(String.self, forKey: .key)
                guard detailKey == "qiwiwallet.telephoneNumberPrefix" else { continue }

                phoneExtensions = try detailContainer.decode([PhoneExtension].self, forKey: .items)
            }
        }
        
        self.phoneExtensions = phoneExtensions ?? PhoneExtensionsRepository.get(with: PhoneExtensionsQuery(paymentMethod: .qiwiWallet))
    }
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case details
        case key
        case items
    }
}

/// Describes a country phone extension.
public struct PhoneExtension: Decodable, Equatable {
    
    /// The phone extension.
    public let value: String
    
    /// The ISO country code.
    public let countryCode: String
    
    /// The full country name.
    public var countryDisplayName: String {
        Locale.current.localizedString(forRegionCode: countryCode) ?? ""
    }
    
    /// Initializes a new instance of `PhoneExtension`.
    ///
    /// - Parameters:
    ///   - value: The phone extension.
    ///   - countryCode: The ISO country code.
    public init(value: String, countryCode: String) {
        self.value = value
        self.countryCode = countryCode
    }

    private enum CodingKeys: String, CodingKey {
        case value = "id"
        case countryCode = "name"
    }
    
}
