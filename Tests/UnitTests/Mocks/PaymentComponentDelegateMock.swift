//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen

final class PaymentComponentDelegateMock: PaymentComponentDelegate {

    // MARK: - didSubmit

    var didSubmitCallsCount = 0
    var didSubmitCalled: Bool {
        didSubmitCallsCount > 0
    }

    var didSubmitReceivedArguments: (data: PaymentComponentData, component: PaymentComponent)?
    var onDidSubmit: ((PaymentComponentData, PaymentComponent) -> Void)?
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        didSubmitCallsCount += 1
        didSubmitReceivedArguments = (data: data, component: component)
        onDidSubmit?(data, component)
    }

    // MARK: - didFail

    var didFailCallsCount = 0
    var didFailCalled: Bool {
        didFailCallsCount > 0
    }

    var didFailReceivedArguments: (error: Error, component: PaymentComponent)?
    var onDidFail: ((Error, PaymentComponent) -> Void)?
    func didFail(with error: Error, from component: PaymentComponent) {
        didFailCallsCount += 1
        didFailReceivedArguments = (error: error, component: component)
        onDidFail?(error, component)
    }
}
