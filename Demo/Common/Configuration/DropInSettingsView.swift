//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenCard
import SwiftUI

@available(iOS 13.0.0, *)
internal struct DropInSettingsView: View {
    @ObservedObject internal var viewModel: ConfigurationViewModel

    internal var body: some View {

        NavigationView {
            List {
                Section {
                    Toggle(isOn: $viewModel.allowDisablingStoredPaymentMethods) {
                        Text("Stored Payment Method Removal")
                        Text("Displays a button to remove stored payment methods")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }

                    Toggle(isOn: $viewModel.allowsSkippingPaymentList) {
                        VStack(alignment: .leading) {
                            Text("Skip Payment List")
                        }
                    }
                    Toggle(isOn: $viewModel.allowPreselectedPaymentView) {
                        Text("Allow Preselected PaymentView")
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}
