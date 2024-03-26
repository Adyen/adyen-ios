//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

@available(iOS 13.0.0, *)
internal struct CardSettingsView: View {
    @ObservedObject internal var viewModel: ConfigurationViewModel
    
    internal var body: some View {

        NavigationView {
            List {
                Section(header: Text("Visibility")) {
                    Toggle(isOn: $viewModel.showsHolderNameField) {
                        Text("Holder Name")
                    }
                    
                    Toggle(isOn: $viewModel.showsStorePaymentMethodField) {
                        VStack(alignment: .leading) {
                            Text("Store Payment Method Toggle")
                            Text("(Requires API version 70 or higher)")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                    }
                    Toggle(isOn: $viewModel.showsSecurityCodeField) {
                        Text("Security Code")
                    }
                    Toggle(isOn: $viewModel.installmentsEnabled.animation()) {
                        Text("Installments")
                        Text("(Example values for installments)")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                    if viewModel.installmentsEnabled {
                        Toggle(isOn: $viewModel.showInstallmentAmount) {
                            Text("Installment Amount")
                        }
                    }
                    Toggle(isOn: $viewModel.showCountryFlags) {
                        Text("Show country flags")
                    }
                }
                Section(header: Text("Input Modes")) {
                    Picker("Billing Address mode", selection: $viewModel.addressMode) {
                        ForEach(CardSettings.AddressFormType.allCases, id: \.self) {
                            Text($0.displayName)
                        }
                    }
                    Picker("Social Security Number Mode", selection: $viewModel.socialSecurityNumberMode) {
                        ForEach(CardComponent.FieldVisibility.allCases, id: \.self) {
                            Text($0.displayName)
                        }
                    }
                    Picker("Korean Authentication Mode", selection: $viewModel.koreanAuthenticationMode) {
                        ForEach(CardComponent.FieldVisibility.allCases, id: \.self) {
                            Text($0.displayName)
                        }
                    }
                }
                Section(header: Text("Stored Card")) {
                    Toggle(isOn: $viewModel.showsStoredCardSecurityCodeField) {
                        Text("Security Code")
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

extension CardSettings.AddressFormType {

    public var displayName: String {
        switch self {
        case .full: return "Full"
        case .lookup: return "Lookup (Dummy Data)"
        case .lookupMapKit: return "Lookup (MapKit)"
        case .postalCode: return "Postal code"
        case .none: return "None"
        }
    }
}

extension CardComponent.FieldVisibility {

    public var displayName: String {
        self.rawValue.capitalized
    }
}
