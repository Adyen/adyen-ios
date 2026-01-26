//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Foundation

internal struct AtomeAddressViewModelBuilder: AddressViewModelBuilder {

    internal init() {}

    internal func build(context: AddressViewModelBuilderContext) -> AddressViewModel {
        AddressViewModel(
            labels: [
                .street: .streetFieldTitle,
                .apartment: .apartmentSuiteFieldTitle,
                .houseNumberOrName: .houseNumberFieldTitle,
                .postalCode: .postalCodeFieldTitle
            ],
            placeholder: [
                .street: .streetFieldPlaceholder,
                .apartment: .apartmentSuiteFieldPlaceholder,
                .houseNumberOrName: .houseNumberFieldPlaceholder,
                .postalCode: .postalCodeFieldPlaceholder
            ],
            optionalFields: [.apartment],
            scheme: [
                .item(.street),
                .item(.apartment),
                .split(.houseNumberOrName, .postalCode)
            ]
        )
    }
}
