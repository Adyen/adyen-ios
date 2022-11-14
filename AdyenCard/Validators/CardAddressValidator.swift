//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Validates a card's address field.
public final class CardAddressValidator {

    private let configuration: CardComponent.Configuration

    private let address: PostalAddress?

    private let addressScheme: [AddressFormScheme]?

    /// Create new instance of CardAddressValidator
    /// - Parameters:
    ///   - configuration: The configurations of the `CardComponent`.
    ///   - address: The postal address.
    ///   - addressScheme: The array of AddressFormScheme
    internal init(configuration: CardComponent.Configuration,
                  address: PostalAddress?,
                  addressScheme: [AddressFormScheme]? = nil) {
        self.configuration = configuration
        self.address = address
        self.addressScheme = addressScheme
    }

    internal var validAddress: PostalAddress? {
        guard let address = address, isAddressValid(address: address) else { return nil }
        return address
    }

    private func isAddressValid(address: PostalAddress) -> Bool {
        let fieldsValues: [String?]

        switch configuration.billingAddress.mode {
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
