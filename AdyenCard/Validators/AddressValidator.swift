//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//
@_spi(AdyenInternal) import Adyen
import Foundation

/// Validates a card's address field.
internal class AddressValidator {

    internal func isValid(address: PostalAddress?, addressMode: CardComponent.AddressFormType, addressViewModel: AddressViewModel) -> Bool {

        let fieldsValues: [String: String?]
        let allAddressFieldsInScheme: [AddressField] = addressViewModel.schema.flatMap(\.children)
        let optionalAddressField: [AddressField] = addressViewModel.optionalFields

        switch addressMode {
        case .full:
            fieldsValues = [AddressField.city.rawValue: address?.city,
                            AddressField.country.rawValue: address?.country,
                            AddressField.postalCode.rawValue: address?.postalCode,
                            AddressField.stateOrProvince.rawValue: address?.stateOrProvince,
                            AddressField.street.rawValue: address?.street,
                            AddressField.houseNumberOrName.rawValue: address?.houseNumberOrName]
        case .postalCode:
            fieldsValues = [AddressField.postalCode.rawValue: address?.postalCode]
        case .none:
            fieldsValues = [:]
        }

        let allAddressFieldsInSchemeSet: Set<AddressField> = Set(allAddressFieldsInScheme)
        let optionalAddressFieldsSet: Set<AddressField> = Set(optionalAddressField)

        let remainingRequiredAddressFields = allAddressFieldsInSchemeSet.subtracting(optionalAddressFieldsSet)

        let isAllRequiredAddressFieldsPresent = checkIfAllFieldsPresent(fieldsValues: fieldsValues,
                                                                        requiredAddressFields: remainingRequiredAddressFields)
        return isAllRequiredAddressFieldsPresent
    }

    private func checkIfAllFieldsPresent(fieldsValues: [String: String?], requiredAddressFields: Set<AddressField>) -> Bool {
        requiredAddressFields.allSatisfy { fieldsValues[$0.rawValue] != nil }
    }
}
