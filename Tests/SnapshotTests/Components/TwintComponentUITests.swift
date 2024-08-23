//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenTwint

class TwintComponentUITests: XCTestCase {

    var paymentMethod: TwintPaymentMethod!
    var context: AdyenContext!
    var sut: TwintComponent!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = TwintPaymentMethod(type: .twint, name: "Twint")
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        paymentMethod = nil
        context = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testTwintWhenShowsStorePaymentMethodFieldIsEnabledShouldDisplayStoreDetailsToggleItem() throws {
        // Given
        let configuration = TwintComponentConfiguration(showsStorePaymentMethodField: true)
        sut = TwintComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentComponentDelegate = PaymentComponentDelegateMock()
        sut.delegate = paymentComponentDelegate

        setupRootViewController(sut.viewController)

        // When
        let view: UIView = sut.viewController.view
        let storeDetailsToggle: FormToggleItemView? = view.findView(by: TwintViewIdentifier.storeDetailsToogle)
        let submitButton: UIControl? = view.findView(by: TwintViewIdentifier.submitButton) as? UIControl

        // Then
        XCTAssertNotNil(storeDetailsToggle, "TwintComponent must show a toggle item.")
        XCTAssertNotNil(submitButton)
    }

    func testTwintWhenShowsStorePaymentMethodFieldIsDisabledShouldNotDisplayStoreDetailsToggleItem() throws {
        // Given
        let configuration = TwintComponentConfiguration(showsStorePaymentMethodField: false)
        sut = TwintComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentComponentDelegate = PaymentComponentDelegateMock()
        sut.delegate = paymentComponentDelegate

        setupRootViewController(sut.viewController)

        // When
        let view: UIView = sut.viewController.view
        let storeDetailsToggle: FormToggleItemView? = view.findView(by: TwintViewIdentifier.storeDetailsToogle)
        let submitButton: UIControl? = view.findView(by: TwintViewIdentifier.submitButton) as? UIControl

        // Then
        XCTAssertNil(storeDetailsToggle, "TwintComponent must show a toggle item.")
        XCTAssertNotNil(submitButton)
    }

    func testSubmitWhenShowsStorePaymentFielsDisabledShouldSendPaymentComponentDataWithStorePaymentMethodAsNil() throws {
        // Given
        let configuration = TwintComponentConfiguration(showsStorePaymentMethodField: false)
        sut = TwintComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentComponentDelegate = PaymentComponentDelegateMock()
        sut.delegate = paymentComponentDelegate

        setupRootViewController(sut.viewController)

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called.")
        paymentComponentDelegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === self.sut)

            // Then
            XCTAssertNil(data.storePaymentMethod)

            didSubmitExpectation.fulfill()
        }

        // When
        let view = sut.viewController.view
        let submitButton: UIControl = try XCTUnwrap(view?.findView(by: TwintViewIdentifier.submitButton))
        submitButton.sendActions(for: .touchUpInside)

        wait(for: [didSubmitExpectation], timeout: 10)
    }

    func testSubmitWhenShowsStoreDetailsIsEnabledAndToggleIsEnabledShouldSendPaymentComponentDataWithStorePaymentMethodTrue() throws {
        // Given
        let configuration = TwintComponentConfiguration(showsStorePaymentMethodField: true)
        sut = TwintComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentComponentDelegate = PaymentComponentDelegateMock()
        sut.delegate = paymentComponentDelegate

        setupRootViewController(sut.viewController)

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called.")
        paymentComponentDelegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === self.sut)

            // Then
            XCTAssertTrue(data.storePaymentMethod ?? false)

            didSubmitExpectation.fulfill()
        }

        // When
        let view = sut.viewController.view
        let storeDetailsToggle: FormToggleItemView = try XCTUnwrap(view?.findView(by: TwintViewIdentifier.storeDetailsToogle))
        let submitButton: UIControl = try XCTUnwrap(view?.findView(by: TwintViewIdentifier.submitButton))

        storeDetailsToggle.item.value = true
        submitButton.sendActions(for: .touchUpInside)

        wait(for: [didSubmitExpectation], timeout: 10)
    }

    func testSubmitWhenShowsStoreDetailsIsEnabledAndToggleIsDisabledShouldSendPaymentComponentDataWithStorePaymentMethodFalse() throws {
        // Given
        let configuration = TwintComponentConfiguration(showsStorePaymentMethodField: true)
        sut = TwintComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentComponentDelegate = PaymentComponentDelegateMock()
        sut.delegate = paymentComponentDelegate

        setupRootViewController(sut.viewController)

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called.")
        paymentComponentDelegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === self.sut)

            // Then
            XCTAssertFalse(data.storePaymentMethod ?? true)

            didSubmitExpectation.fulfill()
        }

        // When
        let view = sut.viewController.view
        let storeDetailsToggle: FormToggleItemView = try XCTUnwrap(view?.findView(by: TwintViewIdentifier.storeDetailsToogle))
        let submitButton: UIControl = try XCTUnwrap(view?.findView(by: TwintViewIdentifier.submitButton))

        storeDetailsToggle.item.value = false
        submitButton.sendActions(for: .touchUpInside)

        wait(for: [didSubmitExpectation], timeout: 10)
    }

    func testStopLoading() {
        // Given
        let configuration = TwintComponent.Configuration()
        sut = TwintComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))

        XCTAssertFalse(sut.submitButtonItem.showsActivityIndicator)
        sut.submitButtonItem.showsActivityIndicator = true

        // When
        sut.stopLoadingIfNeeded()

        // Then
        XCTAssertFalse(sut.submitButtonItem.showsActivityIndicator)
    }

    // MARK: - Private

    private enum TwintViewIdentifier {
        static let storeDetailsToogle = "AdyenTwint.TwintComponent.storeDetailsItem"
        static let submitButton = "AdyenTwint.TwintComponent.submitButtonItem.button"
    }
}
