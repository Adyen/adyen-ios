//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

internal struct ApplePaySettingsView: View {
    @ObservedObject internal var viewModel: ConfigurationViewModel

    private enum ConfigurationSection {
        static let merchantIdentifier = "merchant.com.domainname.appname"
    }

    internal var body: some View {
        NavigationView {
            List {
                Section {
                    TextFieldItemView(
                        title: "Merchant Identifier",
                        value: $viewModel.applePayMerchantIdentifier,
                        placeholder: ConfigurationSection.merchantIdentifier,
                        keyboardType: .default
                    )
                    Toggle(isOn: $viewModel.allowOnboarding) {
                        Text("Allow OnBoarding")
                    }
                    Toggle(isOn: $viewModel.applePayDidAuthorizeSuccessful) {
                        Text("Return success from didAuthorize")
                        Text("When false, simulates a shipping error returned from the didAuthorize delegate method.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                }
                Section(header: Text("Session Callbacks")) {
                    Picker("onBeforeSubmit", selection: $viewModel.applePayOnBeforeSubmitMode) {
                        ForEach(ApplePaySettings.OnBeforeSubmitMode.allCases, id: \.self) {
                            Text($0.displayName)
                        }
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

extension ApplePaySettings.OnBeforeSubmitMode {

    public var displayName: String {
        switch self {
        case .updateData: return "Update data"
        case .abort: return "Abort"
        case .patchSession: return "Patch session"
        }
    }
}
