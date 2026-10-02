//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

internal struct BillingAddressSummary: View {
    internal let viewModel: BillingAddressSummaryViewModel

    internal init(billingAddress: BillingAddressModeDemoSetting) {
        self.viewModel = BillingAddressSummaryViewModel(billingAddress: billingAddress)
    }

    internal var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Billing Address")
                Spacer()
                Text(viewModel.displayName)
                    .foregroundColor(.primary)
            }
            if let hiddenBrandsSummary = viewModel.hiddenBrandsSummary {
                Text("Hide for brands: \(hiddenBrandsSummary)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            if let supportedCountryCodesSummary = viewModel.supportedCountryCodesSummary {
                Text("Supported countries: \(supportedCountryCodesSummary)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    List {
        BillingAddressSummary(
            billingAddress: .full(
                supportedCountryCodes: ["US", "NL", "GB"],
                hideForCardBrands: [CardBrand.visa.rawValue, CardBrand.masterCard.rawValue]
            )
        )
    }
}
