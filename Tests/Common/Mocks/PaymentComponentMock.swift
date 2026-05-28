//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

class PaymentComponentMock: PaymentComponent {

    var context: AdyenContext = Dummy.context

    var paymentMethod: PaymentMethod

    var delegate: PaymentComponentDelegate?

    /// Default type - subclasses provide their own implementation
    var type: PaymentComponentType {
        fatalError("Subclasses must override type")
    }

    init(paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
    }
}

class PresentableComponentMock: PaymentComponentMock, PresentableComponent, LoadingComponent {

    // MARK: - Properties

    var viewController: UIViewController

    override var type: PaymentComponentType {
        .regular(self)
    }

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

    override var type: PaymentComponentType {
        .initiable(self)
    }

    override init(paymentMethod: PaymentMethod) {
        super.init(paymentMethod: paymentMethod)
    }

    // MARK: - initiatePayment

    var initiatePaymentCallsCount = 0
    var initiatePaymentCalled: Bool {
        initiatePaymentCallsCount > 0
    }

    var onInitiatePayment: (() -> Void)?

    func initiatePayment(delegate: any PaymentComponentDelegate) {
        initiatePaymentCallsCount += 1
        onInitiatePayment?()
    }
}
