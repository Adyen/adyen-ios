//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class GenericPaymentComponentTests: XCTestCase {

    private var paymentMethod: GiftCardPaymentMethod!
    private var delegate: PaymentComponentDelegateMock!
    private var sut: GenericPaymentComponent!
    private var context: AdyenContext!

    override func setUp() {
        super.setUp()
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context

        delegate = PaymentComponentDelegateMock()
        paymentMethod = GiftCardPaymentMethod(type: .giftcard, name: "name", brand: "brand")
        sut = GenericPaymentComponent(
            paymentMethod: paymentMethod,
            context: context,
            paymentData: paymentComponentData
        )
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        context = nil
        paymentMethod = nil
        delegate = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testRequiresUserInteractionIsFalse() {
        XCTAssertFalse(sut.requiresUserInteraction)
    }

    func testCustomPaymentData() throws {
        sut.performSubmit()

        let arguments = try XCTUnwrap(delegate.didSubmitReceivedArguments)
        XCTAssertTrue(arguments.component === sut)
        let details = try XCTUnwrap(arguments.data.paymentMethod as? GiftCardDetails)
        XCTAssertEqual(details.brand, "brand")
        XCTAssertEqual(details.encryptedCardNumber, "card")
        XCTAssertEqual(details.encryptedSecurityCode, "cvc")
    }

    func testViewControllerHasCorrectTitle() {
        XCTAssertEqual(sut.viewController.title, paymentMethod.displayInformation(using: nil).title)
    }

    func testTappingPayButtonShouldCallPaymentComponentDelegateDidSubmit() throws {
        sut.viewController.loadViewIfNeeded()

        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(by: "payButtonItem.button")
        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        let component = try XCTUnwrap(delegate.didSubmitReceivedArguments?.component)
        XCTAssertTrue(component === sut)
    }

    func testPerformSubmitStartsLoadingOnPayButton() throws {
        sut.viewController.loadViewIfNeeded()
        let payButton: FormButton = try XCTUnwrap(sut.viewController.view.findView(by: "payButtonItem.button"))
        XCTAssertFalse(payButton.showsActivityIndicator)

        sut.performSubmit()

        XCTAssertTrue(payButton.showsActivityIndicator)
    }

    func testStopLoadingStopsActivityIndicatorOnPayButton() throws {
        sut.viewController.loadViewIfNeeded()
        let payButton: FormButton = try XCTUnwrap(sut.viewController.view.findView(by: "payButtonItem.button"))

        sut.performSubmit()
        XCTAssertTrue(payButton.showsActivityIndicator)

        sut.stopLoading()

        XCTAssertFalse(payButton.showsActivityIndicator)
    }

    // MARK: - Private

    private var paymentComponentData: PaymentComponentData {
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        return PaymentComponentData(paymentMethodDetails: details, order: nil)
    }
}
