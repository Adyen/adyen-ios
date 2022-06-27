//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Contacts
import Foundation

/// The model for address data.
public struct PostalAddress: Equatable, Encodable {

    internal static let invalidCountry = "ZZ"
    internal static let invalidValue = "null"

    /// Create new instance of postal address.
    public init(city: String? = nil,
                country: String? = nil,
                houseNumberOrName: String? = nil,
                postalCode: String? = nil,
                stateOrProvince: String? = nil,
                street: String? = nil,
                apartment: String? = nil) {
        self.city = city
        self.country = country
        self.houseNumberOrName = houseNumberOrName
        self.postalCode = postalCode
        self.stateOrProvince = stateOrProvince
        self.street = street
        self.apartment = apartment
    }

    /// The name of the city.
    public var city: String?

    /// The two-character country code as defined in ISO-3166-1 alpha-2. For example, US.
    /// If you don't know the country or are not collecting the country from the shopper, provide country as ZZ.
    public var country: String?

    /// The number or name of the house.
    public var houseNumberOrName: String?

    /// A maximum of five digits for an address in the US, or a maximum of ten characters for an address in all other countries.
    public var postalCode: String?

    /// State or province codes as defined in ISO 3166-2. For example, CA in the US or ON in Canada.
    /// Required for the US and Canada.
    public var stateOrProvince: String?

    /// The name of the street.
    /// The house number should not be included in this field; it should be separately provided via houseNumberOrName.
    public var street: String?

    /// The name or code of apartment. Optional.
    /// Will be included into houseNumberOrName.
    public var apartment: String?

    /// Encodes this address info into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let houseNumberOrNameValue = [houseNumberOrName, apartment]
            .compactMap { $0?.adyen.nilIfEmpty }
            .joined(separator: " ")
            .adyen.nilIfEmpty

        try container.encode(city.adyen.nilIfEmpty ?? PostalAddress.invalidValue, forKey: .city)
        try container.encode(country.adyen.nilIfEmpty ?? PostalAddress.invalidCountry, forKey: .country)
        try container.encode(houseNumberOrNameValue ?? PostalAddress.invalidValue, forKey: .houseNumberOrName)
        try container.encode(postalCode.adyen.nilIfEmpty ?? PostalAddress.invalidValue, forKey: .postalCode)
        try container.encode(stateOrProvince.adyen.nilIfEmpty ?? PostalAddress.invalidValue, forKey: .stateOrProvince)
        try container.encode(street.adyen.nilIfEmpty ?? PostalAddress.invalidValue, forKey: .street)
    }

    private enum CodingKeys: String, CodingKey {
        case city
        case country
        case houseNumberOrName
        case postalCode
        case stateOrProvince
        case street
    }
    
    /// :nodoc:
    public static func == (lhs: PostalAddress, rhs: PostalAddress) -> Bool {
        let lhsFields = [lhs.city,
                         lhs.postalCode,
                         lhs.street,
                         lhs.stateOrProvince,
                         lhs.country,
                         lhs.apartment,
                         lhs.houseNumberOrName]
            .map { $0?.trimmingCharacters(in: .whitespaces).adyen.nilIfEmpty }
        
        let rhsFields = [rhs.city,
                         rhs.postalCode,
                         rhs.street,
                         rhs.stateOrProvince,
                         rhs.country,
                         rhs.apartment,
                         rhs.houseNumberOrName]
            .map { $0?.trimmingCharacters(in: .whitespaces).adyen.nilIfEmpty }
        return zip(lhsFields, rhsFields).allSatisfy { $0 == $1 }
    }

}

extension PostalAddress {
    
    /// :nodoc:
    public var formatted: String {
        let address = CNMutablePostalAddress()
        city.map { address.city = $0 }
        country.map { address.isoCountryCode = $0 }
        stateOrProvince.map { address.state = $0 }
        postalCode.map { address.postalCode = $0 }
        address.street = [street, houseNumberOrName, apartment]
            .compactMap { $0 }
            .joined(separator: " ")
        
        return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
    }
    
}
