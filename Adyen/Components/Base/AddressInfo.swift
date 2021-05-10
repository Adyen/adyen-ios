//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The model for address data.
/// :nodoc:
public struct AddressInfo: Equatable, Encodable {

    internal static let invalidCountry = "ZZ"
    internal static let invalidValue = "null"

    /// Create new instance of AddressInfo
    public init(postalCode: String) {
        self.postalCode = postalCode
    }

    /// A maximum of five digits for an address in the US, or a maximum of ten characters for an address in all other countries.
    public var postalCode: String

    /// Encodes this address info into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(AddressInfo.invalidValue, forKey: .city)
        try container.encode(AddressInfo.invalidCountry, forKey: .country)
        try container.encode(AddressInfo.invalidValue, forKey: .houseNumberOrName)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encode(AddressInfo.invalidValue, forKey: .stateOrProvince)
        try container.encode(AddressInfo.invalidValue, forKey: .street)
    }

    private enum CodingKeys: String, CodingKey {
        case city
        case country
        case houseNumberOrName
        case postalCode
        case stateOrProvince
        case street
    }

}
