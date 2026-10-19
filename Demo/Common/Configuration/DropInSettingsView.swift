//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

internal struct DropInSettingsView: View {
    @ObservedObject internal var viewModel: ConfigurationViewModel

    internal var body: some View {

        NavigationView {
            List {
                Section {
                    Toggle(isOn: $viewModel.showRemovePaymentMethodButton) {
                        Text("Session Stored Payment Method Removal")
                        Text("Requests the removal button in the Session response")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }

                    Toggle(isOn: $viewModel.hideStoredPaymentMethods) {
                        Text("Hide Stored Payment Methods")
                    }
                    Toggle(isOn: $viewModel.startWithLastStoredPaymentMethod) {
                        Text("Start With Last Stored Payment Method")
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}
