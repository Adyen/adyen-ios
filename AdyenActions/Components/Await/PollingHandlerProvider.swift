//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

/// Any action that has payment data
internal protocol PaymentDataAware {
    var paymentData: String { get }
}

/// A component that handles Await action's.
internal protocol AnyPollingHandler: ActionComponent, Cancellable {
    func handle(_ action: PaymentDataAware)
}

/// :nodoc:
internal protocol AnyPollingHandlerProvider {

    /// :nodoc:
    func handler(for paymentMethodType: AwaitPaymentMethod) -> AnyPollingHandler
    
    /// :nodoc:
    func handler(for qrPaymentMethodType: QRCodePaymentMethod) -> AnyPollingHandler
}

/// :nodoc:
internal struct PollingHandlerProvider: AnyPollingHandlerProvider {

    /// :nodoc:
    private let apiContext: APIContext

    /// :nodoc:
    private let apiClient: AnyRetryAPIClient

    /// :nodoc:
    internal init(apiContext: APIContext) {
        self.apiContext = apiContext
        self.apiClient = RetryAPIClient(
            apiClient: APIClient(apiContext: apiContext),
            scheduler: BackoffScheduler(queue: .main)
        )
    }

    /// :nodoc:
    internal func handler(for paymentMethodType: AwaitPaymentMethod) -> AnyPollingHandler {
        switch paymentMethodType {
        case .mbway, .blik:
            return createPollingComponent()
        }
    }
    
    /// :nodoc:
    internal func handler(for qrPaymentMethodType: QRCodePaymentMethod) -> AnyPollingHandler {
        switch qrPaymentMethodType {
        case .pix:
            return createPollingComponent()
        }
    }
    
    /// :nodoc:
    private func createPollingComponent() -> AnyPollingHandler {
        PollingComponent(apiContext: apiContext, apiClient: apiClient)
    }
    
}
