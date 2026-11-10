//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
@testable import AdyenTwint
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class TwintComponentTests: XCTestCase {

    private var paymentMethod: TwintPaymentMethod!
    private var delegate: PaymentComponentDelegateMock!
    private var sut: TwintComponent!
    private var context: AdyenContext!

    override func setUp() {
        super.setUp()
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context

        delegate = PaymentComponentDelegateMock()
        paymentMethod = TwintPaymentMethod(type: .twint, name: "twint")
        sut = TwintComponent(
            paymentMethod: paymentMethod,
            context: context
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

    func testCustomPaymentData() throws {
        sut.delegate = delegate

        sut.performSubmit()

        let submitted = try XCTUnwrap(delegate.didSubmitReceivedArguments)
        XCTAssertTrue(submitted.component === sut)
        let details = try XCTUnwrap(submitted.data.paymentMethod as? TwintDetails)
        XCTAssertEqual(details.type, .twint)
        XCTAssertEqual(details.subType, "sdk")
    }

    func testInitiatePaymentShouldCallPaymentComponentDelegateDidSubmit() throws {
        // Given
        let sut = TwintComponent(paymentMethod: paymentMethod, context: context)

        let paymentComponentDelegate = PaymentComponentDelegateMock()
        sut.delegate = paymentComponentDelegate

        // When
        sut.performSubmit()

        // Then
        let submittedComponent = try XCTUnwrap(paymentComponentDelegate.didSubmitReceivedArguments?.component)
        XCTAssertTrue(submittedComponent === sut)
        XCTAssertEqual(paymentComponentDelegate.didSubmitCallsCount, 1)
    }

    func testViewControllerHasCorrectTitle() {
        XCTAssertEqual(sut.viewController.title, paymentMethod.displayInformation(using: nil).title)
    }

    func testTappingPayButtonShouldCallPaymentComponentDelegateDidSubmit() throws {
        sut.viewController.loadViewIfNeeded()

        let payButtonItemViewButton: UIControl? = sut.viewController.view.findView(by: "payButtonItem.button")
        payButtonItemViewButton?.sendActions(for: .touchUpInside)

        let submittedComponent = try XCTUnwrap(delegate.didSubmitReceivedArguments?.component)
        XCTAssertTrue(submittedComponent === sut)
        XCTAssertEqual(delegate.didSubmitCallsCount, 1)
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
        let details = TwintDetails(
            type: paymentMethod,
            subType: "sdk"
        )
        return PaymentComponentData(
            paymentMethodDetails: details,
            order: nil
        )
    }

}
