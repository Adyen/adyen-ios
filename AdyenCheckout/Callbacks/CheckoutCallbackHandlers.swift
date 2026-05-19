//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
#if canImport(AdyenSession)
    import AdyenSession
#endif
import Foundation

@MainActor
package protocol CheckoutCallbackHandling: AnyObject {
    func handleSubmit(_ data: PaymentComponentData) async throws -> SubmitResult
    
    func handleAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult
}

@MainActor
package final class SessionCallbackHandler: CheckoutCallbackHandling {
    private let session: SessionProtocol

    package init(session: SessionProtocol) {
        self.session = session
    }

    package func handleSubmit(_ data: PaymentComponentData) async throws -> SubmitResult {
        try await session.performSubmit(data)
    }

    package func handleAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult {
        try await session.performAdditionalDetails(data)
    }
}

@MainActor
package final class AdvancedCallbackHandler: CheckoutCallbackHandling {
    private let callbackStore: AdvancedCheckoutCallbackStore

    package init(callbackStore: AdvancedCheckoutCallbackStore) {
        self.callbackStore = callbackStore
    }

    package func handleSubmit(_ data: PaymentComponentData) async throws -> SubmitResult {
        guard let onSubmit = callbackStore.onSubmit else { throw CallbackError.missingSubmitHandler }
        return try await onSubmit(data)
    }

    package func handleAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult {
        guard let onAdditionalDetails = callbackStore.onAdditionalDetails else { throw CallbackError.missingAdditionalDetailsHandler }
        return try await onAdditionalDetails(data)
    }
}

@MainActor
package final class ActionOnlyCallbackHandler: CheckoutCallbackHandling {
    private let callbackStore: ActionOnlyCheckoutCallbackStore

    package init(callbackStore: ActionOnlyCheckoutCallbackStore) {
        self.callbackStore = callbackStore
    }

    package func handleSubmit(_ data: PaymentComponentData) async throws -> SubmitResult {
        throw CallbackError.unsupportedSubmit
    }

    package func handleAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult {
        guard let onAdditionalDetails = callbackStore.onAdditionalDetails else { throw CallbackError.missingAdditionalDetailsHandler }
        return try await onAdditionalDetails(data)
    }
}
