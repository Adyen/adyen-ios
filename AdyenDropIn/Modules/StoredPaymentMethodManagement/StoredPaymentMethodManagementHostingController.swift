//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI
#if canImport(AdyenUI)
    import AdyenUI
#endif
import UIKit

@MainActor
// swiftlint:disable:next type_name
internal final class StoredPaymentMethodManagementHostingController: UIHostingController<StoredPaymentMethodManagementView> {

    internal let viewModel: StoredPaymentMethodManagementViewModel
    internal var onDismissFromNavigation: (() -> Void)?

    internal init(viewModel: StoredPaymentMethodManagementViewModel, theme: CheckoutTheme) {
        self.viewModel = viewModel
        super.init(rootView: StoredPaymentMethodManagementView(viewModel: viewModel, theme: theme))
    }

    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override internal func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent || isBeingDismissed || navigationController?.isBeingDismissed == true {
            onDismissFromNavigation?()
        }
    }
}
