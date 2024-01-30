//
// Copyright (c) 2023 Adyen N.V.
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
                        Text("Disable Stored Payment Methods")
                    }

                    Toggle(isOn: $viewModel.allowsSkippingPaymentList) {
                        VStack(alignment: .leading) {
                            Text("Skip Payment List")
                        }
                    }
                    Toggle(isOn: $viewModel.allowPreselectedPaymentView) {
                        Text("Allow Preselected PaymentView")
                    }
                    Toggle(isOn: $viewModel.cashAppPayEnabled) {
                        Text("Enable CashApp Pay")
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}
