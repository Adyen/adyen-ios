//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

class PaymentComponentMock: PaymentComponent {
    
    var context: AdyenContext = Dummy.context
    
    var paymentMethod: PaymentMethod
    
    var delegate: PaymentComponentDelegate?
    
    init(paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
    }
}

class PresentableComponentMock: PaymentComponentMock, PresentableComponent {

    // MARK: - Properties

    var viewController: UIViewController

    // MARK: - Initializers

    init(
        paymentMethod: PaymentMethod,
        viewController: UIViewController
    ) {
        self.viewController = viewController
        super.init(paymentMethod: paymentMethod)
    }
}

class InitiableComponentMock: PaymentComponentMock, PaymentInitiable {

    // MARK: - initiatePayment

    var initiatePaymentCallsCount = 0
    var initiatePaymentCalled: Bool {
        initiatePaymentCallsCount > 0
    }

    var onInitiatePayment: (() -> Void)?

    func initiatePayment() {
        initiatePaymentCallsCount += 1
        onInitiatePayment?()
    }
}
