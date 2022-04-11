//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal enum AddressField: String, CaseIterable {
    case street
    case houseNumberOrName
    case apartment
    case postalCode
    case city
    case stateOrProvince
    case country
}

internal enum FormScheme {
    case item(AddressField)
    case split(AddressField, AddressField)
}

public struct AddressViewModel {

    internal var labels: [AddressField: LocalizationKey]
    internal var placeholder: [AddressField: LocalizationKey]
    internal var optionalFields: [AddressField]
    internal var schema: [FormScheme]

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
