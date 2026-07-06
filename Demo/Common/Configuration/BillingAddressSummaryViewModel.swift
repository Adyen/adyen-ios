//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard

internal struct BillingAddressSummaryViewModel {

    private let billingAddress: BillingAddressSetting

    internal init(billingAddress: BillingAddressSetting) {
        self.billingAddress = billingAddress
    }

    internal var displayName: String {
        billingAddress.displayName
    }

    internal var hiddenBrandsSummary: String? {
        guard let brands = hideForCardBrands, !brands.isEmpty else { return nil }
        return brands
            .map { CardBrand(rawValue: $0).name }
            .sorted()
            .joined(separator: ", ")
    }

    internal var supportedCountryCodesSummary: String? {
        guard let countryCodes = supportedCountryCodes, !countryCodes.isEmpty else { return nil }
        return countryCodes
            .sorted()
            .joined(separator: ", ")
    }

    private var hideForCardBrands: Set<String>? {
        switch billingAddress {
        case .none:
            return nil
        case let .postalCode(brands),
             let .lookup(brands),
             let .lookupMapKit(brands):
            return brands
        case let .full(_, brands):
            return brands
        }
    }

    private var supportedCountryCodes: [String]? {
        guard case let .full(countryCodes, _) = billingAddress else { return nil }
        return countryCodes
    }
}
