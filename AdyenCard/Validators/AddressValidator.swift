//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Validates a card's address field.
internal class AddressValidator {

    internal func isValid(address: PostalAddress?, addressMode: CardComponent.AddressFormType, addressScheme: [AddressFormScheme]?) -> Bool {
        let fieldsValues: [String?]

        switch addressMode {
        case .full:
            fieldsValues = [address?.city,
                            address?.country,
                            address?.postalCode,
                            address?.stateOrProvince,
                            address?.street,
                            address?.houseNumberOrName]
        case .postalCode:
            fieldsValues = [address?.postalCode]
        case .none:
            fieldsValues = []
        }

        let trimmedFieldsValues = fieldsValues.map {
            $0?.trimmingCharacters(in: .whitespaces).adyen.nilIfEmpty
        }
        return trimmedFieldsValues.compactMap { $0 }.count == ((addressScheme?.count ?? 0) + 1)
    }

}
