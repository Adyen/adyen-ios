//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

internal struct BillingAddressSummary: View {
    internal let addressSettings: AddressSettings

    internal var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Billing Address")
                Spacer()
                Text(addressSettings.mode.displayName)
                    .foregroundColor(.primary)
            }
            if addressSettings.mode != .none, !addressSettings.hideForCardBrands.isEmpty {
                Text("Hide: \(hiddenBrandsSummary)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            if addressSettings.mode == .full, !addressSettings.supportedCountryCodes.isEmpty {
                Text("Countries: \(supportedCountryCodesSummary)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var hiddenBrandsSummary: String {
        addressSettings.hideForCardBrands
            .map { CardBrand(rawValue: $0).name }
            .sorted()
            .joined(separator: ", ")
    }

    private var supportedCountryCodesSummary: String {
        addressSettings.supportedCountryCodes
            .sorted()
            .joined(separator: ", ")
    }
}

#Preview {
    List {
        BillingAddressSummary(
            addressSettings: AddressSettings(
                mode: .full,
                hideForCardBrands: [CardBrand.visa.rawValue, CardBrand.masterCard.rawValue],
                supportedCountryCodes: ["US", "NL", "GB"]
            )
        )
    }
}
