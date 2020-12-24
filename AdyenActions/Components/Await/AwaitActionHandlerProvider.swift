//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal protocol AnyAwaitActionHandlerProvider {

    /// :nodoc:
    func handler(for paymentMethodType: AwaitPaymentMethod) -> AnyAwaitActionHandler
}

/// :nodoc:
internal struct AwaitActionHandlerProvider: AnyAwaitActionHandlerProvider {

    /// :nodoc:
    private let environment: APIEnvironment

    /// :nodoc:
    private let apiClient: AnyRetryAPIClient?

    /// :nodoc:
    internal init(environment: APIEnvironment, apiClient: AnyRetryAPIClient?) {
        self.environment = environment
        self.apiClient = apiClient
    }

    /// :nodoc:
    internal func handler(for paymentMethodType: AwaitPaymentMethod) -> AnyAwaitActionHandler {
        switch paymentMethodType {
        case .mbway, .blik:
            let scheduler = BackoffScheduler(queue: .main)
            let baseAPIClient = APIClient(environment: environment)
            let apiClient = self.apiClient ?? RetryAPIClient(apiClient: baseAPIClient, scheduler: scheduler)
            return PollingAwaitComponent(apiClient: apiClient)
        }
    }
}
