//
// Copyright (c) Adyen N.V.
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

class PresentableComponentMock: PaymentComponentMock, PresentableComponent, LoadingComponent {

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

    // MARK: - stopLoading

    var stopLoadingCallsCount = 0
    var stopLoadingCalled: Bool {
        stopLoadingCallsCount > 0
    }

    var stopLoadingClosure: (() -> Void)?

    func stopLoading() {
        stopLoadingCallsCount += 1
        stopLoadingClosure?()
    }
}

class InitiableComponentMock: PaymentComponentMock, InitiablePaymentComponent {

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
