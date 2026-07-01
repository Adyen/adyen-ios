//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

internal struct BillingAddressModeSettingsView: View {
    @Binding internal var addressSettings: AddressSettings

    @State private var isHideForCardBrandsExpanded = false
    @State private var isSupportedCountryCodesExpanded = false

    internal var body: some View {
        List {
            Section(header: Text("Mode")) {
                ForEach(AddressSettings.AddressFormType.allCases, id: \.self) { mode in
                    Button {
                        addressSettings.mode = mode
                    } label: {
                        HStack {
                            Text(mode.displayName)
                                .foregroundColor(.primary)
                            Spacer()
                            if addressSettings.mode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }

            if addressSettings.mode != .none {
                SelectableDisclosureSection(
                    title: "Hide For Card Brands",
                    footer: "When a detected card brand matches, the billing address form is hidden.",
                    items: Self.commonBrands,
                    id: \.rawValue,
                    summary: selectedBrandsSummary,
                    isExpanded: $isHideForCardBrandsExpanded,
                    rowTitle: { $0.name },
                    isSelected: { addressSettings.hideForCardBrands.contains($0.rawValue) },
                    onToggle: { addressSettings.toggleBrand($0.rawValue) }
                )
            }

            if addressSettings.mode == .full {
                SelectableDisclosureSection(
                    title: "Supported Country Codes",
                    footer: "Restricts the country picker to selected countries. When none are selected, all countries are available.",
                    items: Self.commonCountryCodes,
                    id: \.self,
                    summary: selectedCountryCodesSummary,
                    isExpanded: $isSupportedCountryCodesExpanded,
                    rowTitle: { String(localized: "\($0) \u{2014} \(Self.countryName(for: $0))") },
                    isSelected: { addressSettings.supportedCountryCodes.contains($0) },
                    onToggle: { addressSettings.toggleCountryCode($0) }
                )
            }
        }
        .navigationTitle("Billing Address")
    }

    private var selectedBrandsSummary: String {
        addressSettings.hideForCardBrands
            .map { CardBrand(rawValue: $0).name }
            .sorted()
            .joined(separator: ", ")
    }

    private var selectedCountryCodesSummary: String {
        addressSettings.supportedCountryCodes
            .sorted()
            .joined(separator: ", ")
    }

    private static let commonBrands: [CardBrand] = [
        .visa, .masterCard, .americanExpress, .maestro,
        .bcmc, .discover, .jcb, .diners
    ]

    private static let commonCountryCodes: [String] = [
        "US", "GB", "NL", "DE", "FR", "BE", "ES", "IT",
        "CA", "AU", "BR", "JP", "CN", "IN", "SG"
    ]

    private static func countryName(for code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}

#Preview {
    BillingAddressModeSettingsPreviewContainer()
}

private struct BillingAddressModeSettingsPreviewContainer: View {
    @State private var addressSettings = AddressSettings(
        mode: .full,
        hideForCardBrands: [CardBrand.visa.rawValue, CardBrand.masterCard.rawValue],
        supportedCountryCodes: ["US", "NL", "GB"]
    )

    var body: some View {
        NavigationView {
            BillingAddressModeSettingsView(addressSettings: $addressSettings)
        }
    }
}
