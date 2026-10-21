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

    private let handler: any CheckoutCallbackHandling
    private let session: SessionProtocol
    private let callbacks: CheckoutCallbacks

    package init(
        handler: any CheckoutCallbackHandling,
        session: SessionProtocol,
        callbacks: CheckoutCallbacks
    ) {
        self.handler = handler
        self.session = session
        self.callbacks = callbacks
    }

    package func handleSubmit(_ data: PaymentComponentData) async throws -> SubmitResult {
        let submitData = try await handleBeforeSubmit(for: data)
        return try await handler.handleSubmit(submitData)
    }

    package func handleAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult {
        try await handler.handleAdditionalDetails(data)
    }

    private func handleBeforeSubmit(for data: PaymentComponentData) async throws -> PaymentComponentData {
        guard let onBeforeSubmit = callbacks.onBeforeSubmit else {
            return data
        }

        let inputData = BeforeSubmitData(
            billingAddress: data.billingAddress,
            deliveryAddress: data.deliveryAddress,
            shopperName: data.shopperName,
            shopperEmail: data.emailAddress
        )
        let result = await onBeforeSubmit(inputData)

        switch result {
        case let .proceed(modifiedData, sessionData):
            if let sessionData {
                try await session.refreshSessionState(with: sessionData)
            }
            return data.replacing(beforeSubmitData: modifiedData)
        case .abort:
            throw CallbackError.beforeSubmitAborted
        }
    }
}

@MainActor
package final class AdvancedCallbackHandler: CheckoutCallbackHandling {
    private let callbacks: AdvancedCheckoutCallbacks

    package init(callbacks: AdvancedCheckoutCallbacks) {
        self.callbacks = callbacks
    }

    package func handleSubmit(_ data: PaymentComponentData) async throws -> SubmitResult {
        await callbacks.onSubmit(data)
    }

    package func handleAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult {
        await callbacks.onAdditionalDetails(data)
    }
}

@MainActor
package final class ActionOnlyCallbackHandler: CheckoutCallbackHandling {
    private let callbacks: ActionOnlyCheckoutCallbacks

    package init(callbacks: ActionOnlyCheckoutCallbacks) {
        self.callbacks = callbacks
    }

    package func handleSubmit(_ data: PaymentComponentData) async throws -> SubmitResult {
        throw CallbackError.unsupportedSubmit
    }

    package func handleAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult {
        await callbacks.onAdditionalDetails(data)
    }
}
