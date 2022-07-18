//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen

final class PaymentComponentDelegateMock: PaymentComponentDelegate {
    var onDidSubmit: ((PaymentComponentData, PaymentComponent) -> Void)?
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        onDidSubmit?(data, component)
    }
    
    var onDidFail: ((Error, PaymentComponent) -> Void)?
    func didFail(with error: Error, from component: PaymentComponent) {
        onDidFail?(error, component)
    }
}
