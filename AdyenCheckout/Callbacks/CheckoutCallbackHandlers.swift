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
package final class BeforeSubmitCallbackHandler: CheckoutCallbackHandling {

    private let innerHandler: any CheckoutCallbackHandling
    private let session: SessionProtocol
    private let callbackStore: SessionCheckoutCallbackStore

    package init(
        inner: any CheckoutCallbackHandling,
        session: SessionProtocol,
        callbackStore: SessionCheckoutCallbackStore
    ) {
        self.innerHandler = inner
        self.session = session
        self.callbackStore = callbackStore
    }

    package func handleSubmit(_ data: PaymentComponentData) async throws -> SubmitResult {
        var submitData = data
        if let onBeforeSubmit = callbackStore.onBeforeSubmit {
            let inputData = BeforeSubmitData(
                billingAddress: data.billingAddress,
                deliveryAddress: data.deliveryAddress,
                shopperName: data.shopperName,
                shopperEmail: data.emailAddress
            )
            let result = try await onBeforeSubmit(inputData)
            switch result {
            case let .proceed(modifiedData, sessionData):
                if let sessionData {
                    try await session.refreshSessionState(with: sessionData)
                }
                submitData = data.applying(modifiedData)
            case .abort:
                throw CallbackError.beforeSubmitAborted
            }
        }
        return try await innerHandler.handleSubmit(submitData)
    }

    package func handleAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult {
        try await innerHandler.handleAdditionalDetails(data)
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
