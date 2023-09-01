//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

@available(iOS 13.0.0, *)
struct CardComponentSettingsView: View {
    @ObservedObject var viewModel: ConfigurationViewModel
    
    var body: some View {

        NavigationView {
            List {
                Section {
                    Toggle(isOn: $viewModel.showsHolderNameField) {
                        Text("Holder Name")
                    }
                    
                    Toggle(isOn: $viewModel.showsStorePaymentMethodField) {
                        VStack(alignment: .leading) {
                            Text("Stored Payment Method")
                            Text("(Requires API version 70 or higher)")
                                .foregroundColor(.gray)
                                .font(.footnote)
                        }
                    }
                    Toggle(isOn: $viewModel.showsSecurityCodeField) {
                        Text("Security Code")
                    }
                    Picker("Select address mode", selection: $viewModel.addressMode) {
                        ForEach(CardComponentConfiguration.AddressFormType.allCases, id: \.self) {
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
    }
}

extension CardComponentConfiguration.AddressFormType {

    public var displayName: String {
        self.rawValue.capitalized
    }
}

extension CardComponent.FieldVisibility {

    public var displayName: String {
        self.rawValue.capitalized
    }
}
