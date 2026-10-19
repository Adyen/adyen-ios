//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCheckout
import XCTest

@MainActor
final class CheckoutPaymentComponentTests: XCTestCase {

    func testRequiresUserInteractionIsTrueForRegularComponent() {
        let paymentMethod = PaymentMethodMock(type: .scheme, name: "Card")
        let paymentComponent = PresentablePaymentComponentMock(
            paymentMethod: paymentMethod,
            viewController: UIViewController()
        )
        let sut = CheckoutPaymentComponent(paymentComponent: paymentComponent)

        XCTAssertTrue(sut.requiresUserInteraction)
    }

    func testRequiresUserInteractionIsTrueForStoredComponent() {
        let paymentMethod = PaymentMethodMock(type: .scheme, name: "Stored Card")
        let paymentComponent = StoredComponentMock(
            paymentMethod: paymentMethod,
            viewController: UIViewController()
        )
        let sut = CheckoutPaymentComponent(paymentComponent: paymentComponent)

        XCTAssertTrue(sut.requiresUserInteraction)
    }

    func testRequiresUserInteractionIsFalseForGenericComponent() {
        let paymentMethod = PaymentMethodMock(type: .applePay, name: "Apple Pay")
        let paymentComponent = PaymentComponentMock(paymentMethod: paymentMethod)
        let sut = CheckoutPaymentComponent(paymentComponent: paymentComponent)

        XCTAssertFalse(sut.requiresUserInteraction)
    }

    func testViewControllerIsForwardedFromThePaymentComponent() {
        let paymentMethod = PaymentMethodMock(type: .scheme, name: "Card")
        let expectedViewController = UIViewController()
        let paymentComponent = PresentablePaymentComponentMock(
            paymentMethod: paymentMethod,
            viewController: expectedViewController
        )
        let sut = CheckoutPaymentComponent(paymentComponent: paymentComponent)

        XCTAssertTrue(sut.viewController === expectedViewController)
    }

    func testSubmitCallsPerformSubmitOnThePaymentComponent() {
        let paymentMethod = PaymentMethodMock(type: .applePay, name: "Apple Pay")
        let paymentComponent = PaymentComponentMock(paymentMethod: paymentMethod)
        let sut = CheckoutPaymentComponent(paymentComponent: paymentComponent)

        sut.submit()

        XCTAssertTrue(paymentComponent.submitCalled)
    }
}
