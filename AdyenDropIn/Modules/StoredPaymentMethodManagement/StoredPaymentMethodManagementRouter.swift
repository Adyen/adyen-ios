//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

@MainActor
internal protocol StoredPaymentMethodManagementListener: AnyObject {
    func didRemoveStoredPaymentMethod(_ paymentMethod: any StoredPaymentMethod)
    func didRequestPaymentOptions()
    func didDismissStoredPaymentMethodManagement()
}

@MainActor
internal protocol StoredPaymentMethodManagementRouting: AnyObject {
    func didRemove(paymentMethod: any StoredPaymentMethod)
    func didRequestPaymentOptions()
}

@MainActor
internal final class StoredPaymentMethodManagementRouter: Router, StoredPaymentMethodManagementRouting {

    // MARK: - Properties

    internal let rootViewController: UIViewController
    private weak var listener: StoredPaymentMethodManagementListener?
    internal let childRouter: Router? = nil
    private var isDismissHandled = false

    // MARK: - Initializers

    internal init(
        rootViewController: UIViewController,
        listener: StoredPaymentMethodManagementListener?
    ) {
        self.rootViewController = rootViewController
        self.listener = listener
    }

    // MARK: - StoredPaymentMethodManagementRouting

    internal func didRemove(paymentMethod: any StoredPaymentMethod) {
        listener?.didRemoveStoredPaymentMethod(paymentMethod)
    }

    internal func didRequestPaymentOptions() {
        listener?.didRequestPaymentOptions()
    }

    // MARK: - Lifecycle

    internal func didDismissFromNavigation() {
        guard !isDismissHandled else {
            return
        }

        isDismissHandled = true
        listener?.didDismissStoredPaymentMethodManagement()
    }
}
