//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

#if canImport(AdyenUI)
    import AdyenUI
#endif

// sourcery:AutoMockable
@MainActor
internal protocol PaymentActionViewModelProtocol: AnyObject {
    var theme: CheckoutTheme { get }
    func cancel()
}

@MainActor
internal class PaymentActionViewModel: PaymentActionViewModelProtocol {

    // MARK: - Properties

    internal let theme: CheckoutTheme
    internal weak var router: PaymentActionRouting?
    private let onCancel: () -> Void

    // MARK: - Initializers

    internal init(
        theme: CheckoutTheme,
        onCancel: @escaping () -> Void
    ) {
        self.theme = theme
        self.onCancel = onCancel
    }

    // MARK: - PaymentActionViewModelProtocol

    /// Dismissing an action dismisses the drop in,
    /// as there is no way back to the payment details of the selected payment method.
    internal func cancel() {
        router?.dismiss(completion: onCancel)
    }
}
