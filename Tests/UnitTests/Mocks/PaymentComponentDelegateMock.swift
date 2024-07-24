//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen

final class PaymentComponentDelegateMock: PaymentComponentDelegate {
    
    init(
        onDidSubmit: ((PaymentComponentData, PaymentComponent) -> Void)? = nil,
        onDidFail: ((Error, PaymentComponent) -> Void)? = nil
    ) {
        self.onDidSubmitClosure = onDidSubmit
        self.onDidFailClosure = onDidFail
    }
    
    // MARK: - onDidSubmit

    var onDidSubmitCallsCount = 0
    var onDidSubmitCalled: Bool {
        onDidSubmitCallsCount > 0
    }

    var onDidSubmitReceivedArguments: (data: PaymentComponentData, component: PaymentComponent)?
    var onDidSubmitClosure: ((PaymentComponentData, PaymentComponent) -> Void)?
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        onDidSubmitCallsCount += 1
        onDidSubmitReceivedArguments = (data: data, component: component)
        onDidSubmitClosure?(data, component)
    }

    // MARK: - onDidFail

    var onDidFailCallsCount = 0
    var onDidFailCalled: Bool {
        onDidFailCallsCount > 0
    }

    var onDidFailReceivedArguments: (error: Error, component: PaymentComponent)?
    var onDidFailClosure: ((Error, PaymentComponent) -> Void)?
    func didFail(with error: Error, from component: PaymentComponent) {
        onDidFailCallsCount += 1
        onDidFailReceivedArguments = (error: error, component: component)
        onDidFailClosure?(error, component)
    }
}
