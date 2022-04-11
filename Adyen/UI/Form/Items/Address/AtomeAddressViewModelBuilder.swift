//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public struct AtomeAddressViewModelBuilder: AddressViewModelBuilder {
    
    public init() {}

    public func build(countryCode: String) -> AddressViewModel {
        return AddressViewModel(labels: [.street: .streetFieldTitle,
                                         .apartment: .apartmentSuiteFieldTitle,
                                         .houseNumberOrName: .houseNumberFieldTitle,
                                         .postalCode: .postalCodeFieldTitle],
                                placeholder: [.street: .streetFieldPlaceholder,
                                              .apartment: .apartmentSuiteFieldPlaceholder,
                                              .houseNumberOrName: .houseNumberFieldPlaceholder,
                                              .postalCode: .postalCodeFieldPlaceholder],
                                optionalFields: [.apartment],
                                schema: [.item(.street),
                                         .item(.apartment),
                                         .split(.houseNumberOrName, .postalCode)])
    }
}
