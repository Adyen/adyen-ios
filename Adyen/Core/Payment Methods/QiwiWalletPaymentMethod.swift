//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A Qiwi Wallet payment method.
public struct QiwiWalletPaymentMethod: PaymentMethod {
    
    /// :nodoc:
    public let type: String
    
    /// :nodoc:
    public let name: String
    
    /// Qiwi Wallet details.
    /// :nodoc:
    public let phoneExtensions: [PhoneExtension]
    
    /// Initializes the Qiwi Wallet payment method.
    ///
    /// - Parameter type: The payment method type.
    /// - Parameter name: The payment method name.
    /// - Parameter phoneExtensions: The phone extensions supported.
    /// :nodoc:
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
    
    /// :nodoc:
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
/// :nodoc:
public struct PhoneExtension: Decodable, Equatable {
    
    /// The phone extension.
    /// :nodoc:
    public let value: String
    
    /// The ISO country code.
    /// :nodoc:
    public let countryCode: String
    
    /// The full country name.
    /// :nodoc:
    public var countryDisplayName: String {
        Locale.current.localizedString(forRegionCode: countryCode) ?? ""
    }

    /// :nodoc:
    public init(value: String, countryCode: String) {
        self.value = value
        self.countryCode = countryCode
    }

    /// :nodoc:
    private enum CodingKeys: String, CodingKey {
        case value = "id"
        case countryCode = "name"
    }
    
}
