//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

@available(iOS 13.0.0, *)
internal struct ApplePaySettingsView: View {
    @ObservedObject internal var viewModel: ConfigurationViewModel

    private enum ConfigurationSection: String, CaseIterable {
        case merchantIdentifier = "{YOUR_APPLE_PAY_MERCHANT_IDENTIFIER}"
    }

    internal var body: some View {
        NavigationView {
            List {
                Section {
                    TextFieldItemView(title: "Merchant Identifier",
                                      value: $viewModel.applePayMerchantIdentifier,
                                      placeholder: ConfigurationSection.merchantIdentifier.rawValue,
                                      keyboardType: .default)
                    Toggle(isOn: $viewModel.allowOnboarding) {
                        Text("Allow OnBoarding")
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}
