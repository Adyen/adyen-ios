//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
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

internal protocol AnyPollingHandlerProvider {

    func handler(for paymentMethodType: AwaitPaymentMethod) -> AnyPollingHandler
    
    func handler(for qrPaymentMethodType: QRCodePaymentMethod) -> AnyPollingHandler
}

internal struct PollingHandlerProvider: AnyPollingHandlerProvider {

    private let apiContext: APIContext

    private let apiClient: AnyRetryAPIClient

    internal init(apiContext: APIContext) {
        self.apiContext = apiContext
        self.apiClient = RetryAPIClient(
            apiClient: APIClient(apiContext: apiContext),
            scheduler: BackoffScheduler(queue: .main)
        )
    }

    internal func handler(for paymentMethodType: AwaitPaymentMethod) -> AnyPollingHandler {
        switch paymentMethodType {
        case .mbway, .blik:
            return createPollingComponent()
        }
    }
    
    internal func handler(for qrPaymentMethodType: QRCodePaymentMethod) -> AnyPollingHandler {
        switch qrPaymentMethodType {
        case .pix:
            return createPollingComponent()
        }
    }
    
    private func createPollingComponent() -> AnyPollingHandler {
        PollingComponent(apiContext: apiContext, apiClient: apiClient)
    }
    
}
