//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// :nodoc:
public enum AddressField: String, CaseIterable {
    case street
    case houseNumberOrName
    case apartment
    case postalCode
    case city
    case stateOrProvince
    case country
}

/// :nodoc:
public enum FormScheme {
    /// :nodoc:
    public var children: [AddressField] {
        switch self {
        case let .item(item): return [item]
        case let .split(item1, item2): return [item1, item2]
        }
    }

    /// :nodoc:
    case item(AddressField)
    /// :nodoc:
    case split(AddressField, AddressField)
}

internal struct AddressViewModelBuilderContext {
    internal var countryCode: String
    internal var isOptional: Bool
}

/// :nodoc:
public struct AddressViewModel {

    internal var labels: [AddressField: LocalizationKey]
    internal var placeholder: [AddressField: LocalizationKey]
    /// :nodoc:
    public private(set) var optionalFields: [AddressField]
    /// :nodoc:
    public private(set) var schema: [FormScheme]

    // swiftlint:disable function_body_length explicit_acl
    internal static subscript(context: AddressViewModelBuilderContext) -> AddressViewModel {
        var viewModel = AddressViewModel(labels: [.city: .cityFieldTitle,
                                                  .houseNumberOrName: .houseNumberFieldTitle,
                                                  .street: .streetFieldTitle,
                                                  .stateOrProvince: .provinceOrTerritoryFieldTitle,
                                                  .postalCode: .postalCodeFieldTitle,
                                                  .apartment: .apartmentSuiteFieldTitle],
                                         placeholder: [.city: .cityFieldPlaceholder,
                                                       .houseNumberOrName: .houseNumberFieldPlaceholder,
                                                       .street: .streetFieldPlaceholder,
                                                       .stateOrProvince: .provinceOrTerritoryFieldPlaceholder,
                                                       .postalCode: .postalCodeFieldPlaceholder,
                                                       .apartment: .apartmentSuiteFieldPlaceholder],
                                         optionalFields: context.isOptional ? AddressField.allCases : [.apartment],
                                         schema: AddressField.allCases.filter { $0 != .country }.map { .item($0) })
        switch context.countryCode {
        case "BR":
            viewModel.labels[.stateOrProvince] = .stateFieldTitle
            viewModel.placeholder[.stateOrProvince] = .selectStateOrProvinceFieldPlaceholder
        case "CA":
            viewModel.labels[.houseNumberOrName] = .apartmentSuiteFieldTitle
            viewModel.labels[.stateOrProvince] = .provinceOrTerritoryFieldTitle
            viewModel.labels[.street] = .addressFieldTitle
            viewModel.placeholder[.houseNumberOrName] = .apartmentSuiteFieldPlaceholder
            viewModel.placeholder[.stateOrProvince] = .provinceOrTerritoryFieldPlaceholder
            viewModel.placeholder[.street] = .addressFieldPlaceholder
            viewModel.optionalFields = context.isOptional ? AddressField.allCases : [.houseNumberOrName]
            viewModel.schema = [.street, .houseNumberOrName, .city, .postalCode, .stateOrProvince].map { .item($0) }
        case "GB":
            viewModel.labels[.city] = .cityTownFieldTitle
            viewModel.placeholder[.city] = .cityTownFieldPlaceholder
            viewModel.schema = [.houseNumberOrName, .street, .city, .postalCode].map { .item($0) }
        case "US":
            viewModel.labels[.postalCode] = .zipCodeFieldTitle
            viewModel.labels[.houseNumberOrName] = .apartmentSuiteFieldTitle
            viewModel.labels[.stateOrProvince] = .stateFieldTitle
            viewModel.labels[.street] = .addressFieldTitle
            viewModel.placeholder[.postalCode] = .zipCodeFieldPlaceholder
            viewModel.placeholder[.houseNumberOrName] = .apartmentSuiteFieldPlaceholder
            viewModel.placeholder[.stateOrProvince] = .selectStateFieldPlaceholder
            viewModel.placeholder[.street] = .addressFieldPlaceholder
            viewModel.optionalFields = context.isOptional ? AddressField.allCases : [.houseNumberOrName]
            viewModel.schema = [.item(.street),
                                .item(.houseNumberOrName),
                                .item(.city),
                                .split(.stateOrProvince, .postalCode)]
        default:
            break
        }

        return viewModel
    }
    // swiftlint:enable function_body_length explicit_acl
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
