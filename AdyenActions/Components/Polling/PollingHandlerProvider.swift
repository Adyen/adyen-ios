//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

/// A component that handles Await action's.
internal protocol AnyPollingHandler: ActionComponent, Cancellable {
    func handle(_ action: PaymentDataAware)
}

internal protocol AnyPollingHandlerProvider {

    func handler() -> AnyPollingHandler
}

@MainActor
internal struct PollingHandlerProvider: AnyPollingHandlerProvider {

    private let context: AdyenContext

    private let apiClient: AnyRetryAPIClient

    internal init(context: AdyenContext) {
        self.context = context
        self.apiClient = RetryAPIClient(
            apiClient: APIClient(apiContext: context.apiContext),
            scheduler: BackoffScheduler(queue: .main)
        )
    }

    internal func handler() -> AnyPollingHandler {
        PollingComponent(
            context: context,
            apiClient: apiClient
        )
    }
    
}
