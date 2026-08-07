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
        present(actionJSON: DummyAction.voucher)
    }

    internal func presentQRCode() {
        present(actionJSON: DummyAction.qrCode)
    }

    private func present(actionJSON: String) {
        let example = ActionComponentExample(actionJSON: actionJSON)
        example.presenter = presenter
        currentExample = example
        example.start()
    }
}

/// A lightweight list of standalone action examples, used to quickly test action UIs
/// (e.g. `VoucherView`, `QRCodeView`) without completing a full payment flow.
internal struct ActionsView: View {

    @ObservedObject internal var viewModel: ActionsViewModel

    internal var body: some View {
        List {
            Section {
                actionRow(
                    title: "Voucher",
                    subtitle: "Boleto voucher (VoucherView)",
                    action: viewModel.presentVoucher
                )
                actionRow(
                    title: "QR Code",
                    subtitle: "Pix QR code (QRCodeView)",
                    action: viewModel.presentQRCode
                )
            }
        }
        .navigationTitle("Actions")
    }

    private func actionRow(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
