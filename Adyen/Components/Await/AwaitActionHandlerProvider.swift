//
//  AwaitActionHandlerProvider.swift
//  Adyen
//
//  Created by Mohamed Eldoheiri on 8/12/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

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
        case .mbway:
            let scheduler = BackoffScheduler(queue: .main)
            let baseAPIClient = APIClient(environment: environment)
            let apiClient = self.apiClient ?? RetryAPIClient(apiClient: baseAPIClient, scheduler: scheduler)
            return PollingAwaitComponent(apiClient: apiClient)
        }
    }
}
