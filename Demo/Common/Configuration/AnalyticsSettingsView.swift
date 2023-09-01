//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct AnalyticsSettingsView: View {
    @ObservedObject var viewModel: ConfigurationViewModel

    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $viewModel.analyticsIsEnabled) {
                        Text("isEnabled")
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}
