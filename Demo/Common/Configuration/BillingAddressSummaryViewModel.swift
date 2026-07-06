//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard

/// Derives the display strings shown by ``BillingAddressSummary`` from a ``BillingAddressSetting``.
///
/// Each summary is optional: a `nil` value means the corresponding field is not applicable to the
/// selected form (or has no configuration) and should not be shown.
internal struct BillingAddressSummaryViewModel {

    private let billingAddress: BillingAddressSetting

    internal init(billingAddress: BillingAddressSetting) {
        self.billingAddress = billingAddress
    }

    private var formData: AddressFormViewData {
        AddressFormViewData(billingAddress)
    }

    internal var displayName: String {
        billingAddress.displayName
    }

    internal var hiddenBrandsSummary: String? {
        let brands = formData.hideForCardBrands
        guard !brands.isEmpty else { return nil }
        return brands
            .map { CardBrand(rawValue: $0).name }
            .sorted()
            .joined(separator: ", ")
    }

    internal var supportedCountryCodesSummary: String? {
        let countryCodes = formData.supportedCountryCodes
        guard !countryCodes.isEmpty else { return nil }
        return countryCodes
            .sorted()
            .joined(separator: ", ")
    }
}
