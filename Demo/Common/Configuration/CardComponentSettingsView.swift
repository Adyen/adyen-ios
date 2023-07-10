//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

@available(iOS 13.0.0, *)
internal struct CardComponentSettingsView: View {
    @ObservedObject internal var viewModel: ConfigurationViewModel
    
    internal var body: some View {

        NavigationView {
            List {
                Section {
                    Toggle(isOn: $viewModel.showsHolderNameField) {
                        Text("Holder Name")
                    }
                    Toggle(isOn: $viewModel.showsStorePaymentMethodField) {
                        Text("Stored Payment Method")
                    }
                    Toggle(isOn: $viewModel.showsSecurityCodeField) {
                        Text("Security Code")
                    }
                    Picker("Select address mode", selection: $viewModel.addressMode) {
                        ForEach(CardComponent.AddressFormType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    Picker("Social Security Number Mode", selection: $viewModel.socialSecurityNumberMode) {
                        ForEach(CardComponent.FieldVisibility.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    Picker("Korean Authentication Mode", selection: $viewModel.koreanAuthenticationMode) {
                        ForEach(CardComponent.FieldVisibility.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                }
                Section(header: Text("Stored Card")) {
                    Toggle(isOn: $viewModel.showsStoredCardSecurityCodeField) {
                        Text("Security Code")
                    }
                }

            }
        }
        .navigationViewStyle(.stack)
    }
}