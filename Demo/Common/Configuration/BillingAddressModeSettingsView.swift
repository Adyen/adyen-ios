//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

internal struct BillingAddressModeSettingsView: View {
    @Binding internal var billingAddress: BillingAddressSetting

    @State private var isHideForCardBrandsExpanded = false
    @State private var isSupportedCountryCodesExpanded = false

    private var viewModel: BillingAddressModeSettingsViewModel {
        BillingAddressModeSettingsViewModel(billingAddress: $billingAddress)
    }

    internal var body: some View {
        List {
            Section(header: Text("Mode")) {
                ForEach(viewModel.settings, id: \.self) { setting in
                    Button {
                        viewModel.select(setting)
                    } label: {
                        HStack {
                            Text(viewModel.displayName(for: setting))
                                .foregroundColor(.primary)
                            Spacer()
                            if viewModel.isSelected(setting) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }

            if viewModel.showsCardBrandHiding {
                SelectableDisclosureSection(
                    title: "Hide For Card Brands",
                    footer: "When a detected card brand matches, the billing address form is hidden.",
                    items: viewModel.commonBrands,
                    id: \.rawValue,
                    summary: viewModel.selectedBrandsSummary,
                    isExpanded: $isHideForCardBrandsExpanded,
                    rowTitle: { $0.name },
                    isSelected: { viewModel.isBrandSelected($0) },
                    onToggle: { viewModel.toggleBrand($0) }
                )
            }

            if viewModel.showsSupportedCountryCodes {
                SelectableDisclosureSection(
                    title: "Supported Country Codes",
                    footer: "Restricts the country picker to selected countries. When none are selected, all countries are available.",
                    items: viewModel.commonCountryCodes,
                    id: \.self,
                    summary: viewModel.selectedCountryCodesSummary,
                    isExpanded: $isSupportedCountryCodesExpanded,
                    rowTitle: { String(localized: "\($0) - \(viewModel.countryName(for: $0))") },
                    isSelected: { viewModel.isCountryCodeSelected($0) },
                    onToggle: { viewModel.toggleCountryCode($0) }
                )
            }
        }
        .navigationTitle("Billing Address")
    }
}

#Preview {
    BillingAddressModeSettingsPreviewContainer()
}

private struct BillingAddressModeSettingsPreviewContainer: View {
    @State private var billingAddress: BillingAddressSetting = .full(
        supportedCountryCodes: ["US", "NL", "GB"],
        hideForCardBrands: [CardBrand.visa.rawValue, CardBrand.masterCard.rawValue]
    )

    var body: some View {
        NavigationView {
            BillingAddressModeSettingsView(billingAddress: $billingAddress)
        }
    }
}
