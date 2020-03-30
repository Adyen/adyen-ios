//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A Qiwi Wallet paymeny method.
public struct QiwiWalletPaymentMethod: PaymentMethod {
    
    /// :nodoc:
    public let type: String
    
    /// :nodoc:
    public let name: String
    
    /// Qiwi Wallet details.
    internal let phoneExtensions: [PhoneExtension]
    
    /// Initializes the Qiwi Wallet payment method.
    ///
    /// - Parameter type: The payment method type.
    /// - Parameter name: The payment method name.
    /// - Parameter phoneExtensions: The phone extensions supported.
    internal init(type: String, name: String, phoneExtensions: [PhoneExtension] = []) {
        self.type = type
        self.name = name
        self.phoneExtensions = phoneExtensions
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        
        var phoneExtensions: [PhoneExtension]?
        var detailsContainer = try container.nestedUnkeyedContainer(forKey: .details)
        while !detailsContainer.isAtEnd {
            let detailContainer = try detailsContainer.nestedContainer(keyedBy: CodingKeys.self)
            let detailKey = try detailContainer.decode(String.self, forKey: .key)
            guard detailKey == "qiwiwallet.telephoneNumberPrefix" else { continue }
            
            phoneExtensions = try detailContainer.decode([PhoneExtension].self, forKey: .items)
        }
        
        self.phoneExtensions = phoneExtensions ?? []
    }
    
    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        return builder.build(paymentMethod: self)
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
internal struct PhoneExtension: Decodable, Equatable {
    
    /// The phone extension.
    internal let value: String
    
    /// The ISO country code.
    internal let countryCode: String
    
    /// The full country name.
    internal var countryDisplayName: String {
        Locale.current.localizedString(forRegionCode: countryCode) ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case value = "id"
        case countryCode = "name"
    }
    
}
