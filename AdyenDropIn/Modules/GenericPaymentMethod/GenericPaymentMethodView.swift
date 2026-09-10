//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

internal struct GenericPaymentMethodView: View {

    // MARK: - Properties

    @ObservedObject internal var viewModel: GenericPaymentMethodViewModel

    // MARK: - Body

    internal var body: some View {
        VStack {
            AsyncImage(url: <#T##URL?#>)
            Text("Logo")
            Text("\(viewModel.paymentMethodName)")
            Text("Description")
            Text("Loading")

            ProgressView()
                .task {
                    viewModel.startPayment()
                }
        }
    }
}
