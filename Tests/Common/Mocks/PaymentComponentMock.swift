//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenUI

class PaymentComponentMock: PaymentComponent {

    var context: AdyenContext = Dummy.context

    var paymentMethod: PaymentMethod

    var delegate: PaymentComponentDelegate?

    var viewController: UIViewController = .init()

    var type: PaymentComponentType {
        .generic
    }

    init(paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
    }

    // MARK: - submit

    var submitCallsCount = 0
    var submitCalled: Bool {
        submitCallsCount > 0
    }

    var submitClosure: (() -> Void)?

    /// When true, calling submit() will trigger didSubmit on the delegate with mock payment data
    var shouldCallDelegateOnSubmit = true

    func performSubmit() {
        submitCallsCount += 1
        submitClosure?()

        if shouldCallDelegateOnSubmit {
            let details: PaymentMethodDetails
            if let storedPaymentMethod = paymentMethod as? StoredPaymentMethod {
                details = StoredPaymentDetails(paymentMethod: storedPaymentMethod)
            } else {
                details = GenericPaymentDetails(type: paymentMethod.type)
            }
            let data = PaymentComponentData(paymentMethodDetails: details, order: nil)
            delegate?.didSubmit(data, from: self)
        }
    }
}

class PresentablePaymentComponentMock: PaymentComponentMock, LoadingComponent {

    // MARK: - Properties

    override var type: PaymentComponentType {
        .regular
    }

    // MARK: - Initializers

    init(
        paymentMethod: PaymentMethod,
        viewController: UIViewController
    ) {
        super.init(paymentMethod: paymentMethod)
        self.viewController = viewController
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

class StoredComponentMock: PaymentComponentMock, StoredPaymentComponent {

    var order: PartialPaymentOrder?

    override var type: PaymentComponentType {
        .stored
    }

    init(
        paymentMethod: PaymentMethod,
        viewController: UIViewController
    ) {
        super.init(paymentMethod: paymentMethod)
        self.viewController = viewController
    }
}
