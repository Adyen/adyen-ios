//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

// TODO: This resolver will be deleted by the Drop-in callback/configuration task,
// when CheckoutCore provides `StoredPaymentMethodManagementCapability` directly.

/// Resolves the current Drop-in management capability from the legacy removal delegates.
@MainActor
package final class StoredPaymentMethodManagementResolver {

    private weak var dropInComponent: DropInComponent?

    package init(dropInComponent: DropInComponent) {
        self.dropInComponent = dropInComponent
    }

    package var capability: StoredPaymentMethodManagementCapability? {
        guard let dropInComponent,
              let delegate = dropInComponent.storedPaymentMethodsDelegate
        else {
            return nil
        }

        if let sessionDelegate = delegate as? SessionStoredPaymentMethodsDelegate {
            guard sessionDelegate.showRemovePaymentMethodButton else {
                return nil
            }
        } else if !dropInComponent.configuration.paymentMethodsList.allowDisablingStoredPaymentMethods {
            return nil
        }

        return StoredPaymentMethodManagementCapability { [weak self] storedPaymentMethod in
            guard let self else {
                throw StoredPaymentMethodRemovalError.unavailable
            }

            try await self.remove(storedPaymentMethod)
        }
    }

    private func remove(_ storedPaymentMethod: StoredPaymentMethod) async throws {
        guard let dropInComponent,
              let delegate = dropInComponent.storedPaymentMethodsDelegate
        else {
            throw StoredPaymentMethodRemovalError.unavailable
        }

        try await withCheckedThrowingContinuation { continuation in
            let completion = StoredPaymentMethodRemovalCompletion(continuation: continuation)
            let resolve: Completion<Bool> = { success in
                Task {
                    await completion.resolve(success)
                }
            }

            if let sessionDelegate = delegate as? SessionStoredPaymentMethodsDelegate {
                sessionDelegate.disable(
                    storedPaymentMethod: storedPaymentMethod,
                    dropInComponent: dropInComponent,
                    completion: resolve
                )
            } else {
                delegate.disable(storedPaymentMethod: storedPaymentMethod, completion: resolve)
            }
        }
    }
}

private actor StoredPaymentMethodRemovalCompletion {

    private var continuation: CheckedContinuation<Void, Error>?

    init(continuation: CheckedContinuation<Void, Error>) {
        self.continuation = continuation
    }

    func resolve(_ success: Bool) {
        guard let continuation else {
            return
        }

        self.continuation = nil
        continuation.resume(with: success ? .success(()) : .failure(StoredPaymentMethodRemovalError.unsuccessful))
    }
}
