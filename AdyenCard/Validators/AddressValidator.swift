//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Validates a card's address field.
public final class AddressValidator {

    private var addressMode: CardComponent.AddressFormType = .none

    private let address: PostalAddress

    private let addressScheme: [AddressFormScheme]?

    /// Create new instance of CardAddressValidator
    /// - Parameters:
    ///   - configuration: The configurations of the `CardComponent`.
    ///   - address: The postal address.
    ///   - addressScheme: The array of AddressFormScheme
    internal init(addressMode: CardComponent.AddressFormType,
                  address: PostalAddress,
                  addressScheme: [AddressFormScheme]? = nil) {
        self.addressMode = addressMode
        self.address = address
        self.addressScheme = addressScheme
    }

    internal func isValid() -> Bool {
        let fieldsValues: [String?]

        switch addressMode {
        case .full:
            fieldsValues = [address.city,
                            address.country,
                            address.postalCode,
                            address.stateOrProvince,
                            address.street,
                            address.houseNumberOrName]
        case .postalCode:
            fieldsValues = [address.postalCode]
        case .none:
            fieldsValues = []
        }

        let trimmedFieldsValues = fieldsValues.map {
            $0?.trimmingCharacters(in: .whitespaces).adyen.nilIfEmpty
        }
        return trimmedFieldsValues.compactMap { $0 }.count == ((addressScheme?.count ?? 0) + 1)
    }

}
