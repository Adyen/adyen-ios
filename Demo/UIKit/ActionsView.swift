//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

/// Retains the currently running action example and forwards presentation to the host.
@MainActor
internal final class ActionsViewModel: ObservableObject {

    internal weak var presenter: PresenterExampleProtocol?

    private var currentExample: (any InitialDataAdvancedFlowProtocol)?

    internal init(presenter: PresenterExampleProtocol? = nil) {
        self.presenter = presenter
    }

    internal func presentVoucher() {
        let example = VoucherActionExample()
        example.presenter = presenter
        currentExample = example
        example.start()
    }
}

/// A lightweight list of standalone action examples, used to quickly test action UIs
/// (e.g. `VoucherView`) without completing a full payment flow.
internal struct ActionsView: View {

    @ObservedObject internal var viewModel: ActionsViewModel

    internal var body: some View {
        List {
            Section {
                Button(action: viewModel.presentVoucher) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Voucher")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Boleto voucher (VoucherView)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Actions")
    }
}
