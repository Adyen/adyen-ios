//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

@_spi(AdyenInternal)
public enum AddressField: String, CaseIterable {
    case street
    case houseNumberOrName
    case apartment
    case postalCode
    case city
    case stateOrProvince
    case country
}

@_spi(AdyenInternal)
public enum AddressFormScheme {
    public var children: [AddressField] {
        switch self {
        case let .item(item): return [item]
        case let .split(item1, item2): return [item1, item2]
        }
    }

    case item(AddressField)
    case split(AddressField, AddressField)
}

@_spi(AdyenInternal)
public struct AddressViewModel {

    internal var labels: [AddressField: LocalizationKey]
    internal var placeholder: [AddressField: LocalizationKey]

    @_spi(AdyenInternal)
    public var optionalFields: [AddressField]

    @_spi(AdyenInternal)
    public var scheme: [AddressFormScheme]

    public init(labels: [AddressField: LocalizationKey],
                placeholder: [AddressField: LocalizationKey],
                optionalFields: [AddressField],
                scheme: [AddressFormScheme]) {
        self.labels = labels
        self.placeholder = placeholder
        self.optionalFields = optionalFields
        self.scheme = scheme
    }

}

@_spi(AdyenInternal)
public extension AddressViewModel {
    
    /// Returns all fields that are not specified as `optionalFields`
    var requiredFields: Set<AddressField> {
        let allAddressFieldsInScheme: Set<AddressField> = Set(scheme.flatMap(\.children))
        let optionalAddressFields: Set<AddressField> = Set(optionalFields)
        return allAddressFieldsInScheme.subtracting(optionalAddressFields)
    }
}

extension AddressField {

    internal var contentType: UITextContentType? {
        switch self {
        case .street:
            return .streetAddressLine1
        case .houseNumberOrName:
            return .streetAddressLine2
        case .apartment:
            return nil
        case .postalCode:
            return .postalCode
        case .city:
            return .addressCity
        case .stateOrProvince:
            return .addressState
        case .country:
            return .countryName
        }
    }
}

@_spi(AdyenInternal)
public extension PostalAddress {

    /// Validates whether all required fields are filled in and not empty
    func satisfies(requiredFields: Set<AddressField>) -> Bool {

        let fieldsValues = [
            AddressField.city.rawValue: city,
            AddressField.country.rawValue: country,
            AddressField.postalCode.rawValue: postalCode,
            AddressField.stateOrProvince.rawValue: stateOrProvince,
            AddressField.street.rawValue: street,
            AddressField.houseNumberOrName.rawValue: houseNumberOrName,
            AddressField.apartment.rawValue: apartment
        ].compactMapValues { $0 }
        
        let satisfied = checkIfAllFieldsPresent(
            fieldsValues: fieldsValues,
            requiredAddressFields: requiredFields
        )
        
        return satisfied
    }

    private func checkIfAllFieldsPresent(
        fieldsValues: [String: String],
        requiredAddressFields: Set<AddressField>
    ) -> Bool {
        requiredAddressFields.allSatisfy {
            guard let fieldValue = fieldsValues[$0.rawValue] else { return false }
            return !fieldValue.isEmpty
        }
    }
}
