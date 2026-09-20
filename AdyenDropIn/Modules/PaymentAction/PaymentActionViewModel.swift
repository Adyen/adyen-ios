//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol PaymentActionViewModelProtocol: AnyObject {
    func cancel()
}

@MainActor
internal class PaymentActionViewModel: PaymentActionViewModelProtocol {

    // MARK: - Properties

    internal weak var router: PaymentActionRouting?
    private let dropInFlowManager: DropInFlowManaging

    // MARK: - Initializers

    internal init(dropInFlowManager: DropInFlowManaging) {
        self.dropInFlowManager = dropInFlowManager
    }

    // MARK: - PaymentActionViewModelProtocol

    /// Dismissing an action dismisses the drop in,
    /// as there is no way back to the payment details of the selected payment method.
    internal func cancel() {
        router?.dismiss(completion: nil)
        dropInFlowManager.dismissDropIn()
    }
}
