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
                Section(footer: Text("When a detected card brand matches, the billing address form is hidden.")) {
                    DisclosureGroup(isExpanded: $isHideForCardBrandsExpanded) {
                        ForEach(Self.commonBrands, id: \.rawValue) { brand in
                            Button {
                                addressSettings.toggleBrand(brand.rawValue)
                            } label: {
                                HStack {
                                    Text(brand.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if addressSettings.hideForCardBrands.contains(brand.rawValue) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                        }
                    } label: {
                        selectionLabel(title: "Hide For Card Brands", subtitle: selectedBrandsSummary)
                    }
                }
            }

            if addressSettings.mode == .full {
                Section(footer: Text("Restricts the country picker to selected countries. When none are selected, all countries are available.")) {
                    DisclosureGroup(isExpanded: $isSupportedCountryCodesExpanded) {
                        ForEach(Self.commonCountryCodes, id: \.self) { code in
                            Button {
                                addressSettings.toggleCountryCode(code)
                            } label: {
                                HStack {
                                    Text("\(code) \u{2014} \(Self.countryName(for: code))")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if addressSettings.supportedCountryCodes.contains(code) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                        }
                    } label: {
                        selectionLabel(title: "Supported Country Codes", subtitle: selectedCountryCodesSummary)
                    }
                }
            }
        }
        .navigationTitle("Billing Address")
    }

    private func selectionLabel(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .foregroundColor(.primary)
            Text(subtitle.isEmpty ? "None selected" : subtitle)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
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
