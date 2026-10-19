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
                    BillingAddressModeSettingsView(billingAddress: $viewModel.billingAddress)
                } label: {
                    BillingAddressSummary(billingAddress: viewModel.billingAddress)
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

extension CardConfiguration.FieldVisibility {

    internal var displayName: String {
        self.rawValue.capitalized
    }
}
