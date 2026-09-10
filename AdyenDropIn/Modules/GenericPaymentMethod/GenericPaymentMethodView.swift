//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

struct GenericPaymentMethodView: View {

    // MARK: - Properties

    @ObservedObject var viewModel: GenericPaymentMethodViewModel

    // MARK: - Body
    var body: some View {
        VStack {
            Text("Logo")
            Text("\(viewModel.paymentMethodName)")
            Text("Description")
            Text("Loading")
        }
    }
}
