//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

internal struct CardSettingsView: View {
    @ObservedObject internal var viewModel: ConfigurationViewModel
    
    internal var body: some View {
        List {
            Section(header: Text("Visibility")) {
                Toggle(isOn: $viewModel.showCardholderName) {
                    Text("Holder Name")
                }
                
                Toggle(isOn: $viewModel.showStorePaymentMethod) {
                    VStack(alignment: .leading) {
                        Text("Store Payment Method Toggle")
                        Text("(Requires API version 70 or higher)")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
                Toggle(isOn: $viewModel.showSecurityCode) {
                    Text("Security Code")
                }
                Toggle(isOn: $viewModel.installmentsEnabled.animation()) {
                    VStack(alignment: .leading) {
                        Text("Installments")
                        Text("(Example values for installments)")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
                if viewModel.installmentsEnabled {
                    Toggle(isOn: $viewModel.showInstallmentAmount) {
                        Text("Installment Amount")
                    }
                }
            }
            Section(header: Text("Input Modes")) {
                NavigationLink {
                    BillingAddressModeSettingsView(addressSettings: $viewModel.addressSettings)
                } label: {
                    BillingAddressSummary(addressSettings: viewModel.addressSettings)
                }
                Picker("Social Security Number Mode", selection: $viewModel.socialSecurityNumberVisibility) {
                    ForEach(CardConfiguration.FieldVisibility.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
                Picker("Korean Authentication Mode", selection: $viewModel.koreanAuthenticationVisibility) {
                    ForEach(CardConfiguration.FieldVisibility.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
            }
            Section(header: Text("Stored Card")) {
                Toggle(isOn: $viewModel.showSecurityCodeForStoredCard) {
                    Text("Security Code")
                }
            }
        }
    }
}

extension AddressSettings.AddressFormType {

    internal var displayName: String {
        switch self {
        case .full: return "Full"
        case .lookup: return "Lookup (Dummy Data)"
        case .lookupMapKit: return "Lookup (MapKit)"
        case .postalCode: return "Postal code"
        case .none: return "None"
        }
    }
}

extension CardConfiguration.FieldVisibility {

    internal var displayName: String {
        self.rawValue.capitalized
    }
}
