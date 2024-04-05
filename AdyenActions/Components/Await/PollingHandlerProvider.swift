//
// Copyright (c) 2024 Adyen N.V.
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

    private let context: AdyenContext

    private let apiClient: AnyRetryAPIClient

    internal init(context: AdyenContext) {
        self.context = context
        self.apiClient = RetryAPIClient(
            apiClient: APIClient(apiContext: context.apiContext),
            scheduler: BackoffScheduler(queue: .main)
        )
    }

    internal func handler(for paymentMethodType: AwaitPaymentMethod) -> AnyPollingHandler {
        switch paymentMethodType {
        case .mbway, .blik, .upicollect:
            return createPollingComponent()
        }
    }
    
    internal func handler(for qrPaymentMethodType: QRCodePaymentMethod) -> AnyPollingHandler {
        switch qrPaymentMethodType {
        case .pix, .promptPay, .duitNow, .payNow, .upiQRCode:
            return createPollingComponent()
        }
    }
    
    private func createPollingComponent() -> AnyPollingHandler {
        PollingComponent(context: context,
                         apiClient: apiClient)
    }
    
}
