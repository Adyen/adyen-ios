//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class OnlineBankingComponentTests: XCTestCase {

    private var context: AdyenContext!
    private var paymentMethod: OnlineBankingPaymentMethod!
    private var style: FormComponentStyle!
    private var sut: OnlineBankingComponent!
    private var analyticsProviderMock: AnalyticsProviderMock!

    override func setUpWithError() throws {
        paymentMethod = try! AdyenCoder.decode(onlineBankingDictionary) as OnlineBankingPaymentMethod
        analyticsProviderMock = AnalyticsProviderMock()
        context = AdyenContext(apiContext: Dummy.apiContext, payment: nil, analyticsProvider: analyticsProviderMock)
        style = FormComponentStyle()
        sut = OnlineBankingComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: OnlineBankingComponent.Configuration(style: style)
        )
        getFormViewController().title = "Test title"
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        context = nil
        paymentMethod = nil
        style = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testComponent_ShouldPaymentMethodTypeBeOnlineBanking() throws {
        // Given
        let expectedPaymentMethodType: PaymentMethodType = .onlineBankingCZ

        // Action
        let paymentMethodType = sut.paymentMethod.type

        // Assert
        XCTAssertEqual(paymentMethodType, expectedPaymentMethodType)
    }

    func testComponent_ShouldRequireModalPresentation() throws {
        // Assert
        XCTAssertTrue(sut.requiresModalPresentation)
    }

    func testRequiresKeyboardInput() {
        let childViewController = getFormViewController()

        XCTAssertTrue(childViewController.requiresKeyboardInput)
    }

    func testTitle() {
        // Assert
        XCTAssertEqual(getFormViewController().title, "Test title")
    }

    private func getFormViewController() -> FormViewController {
        (sut.viewController as! SecuredViewController<FormViewController>).childViewController
    }

    func testSubmit_shouldCallPaymentDelegateDidSubmit() throws {
        // Given
        let sut = OnlineBankingComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        let didSubmitExpectation = XCTestExpectation(description: "Expected delegate.didSubmit() to be called.")

        let paymentDelegateMock = PaymentComponentDelegateMock()
        sut.delegate = paymentDelegateMock

        paymentDelegateMock.onDidSubmit = { _, component in
            didSubmitExpectation.fulfill()
        }

        // When
        sut.submit()

        // Then
        wait(for: [didSubmitExpectation], timeout: 10)
        XCTAssertEqual(paymentDelegateMock.didSubmitCallsCount, 1)
    }

    func testValidateShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let configuration = OnlineBankingComponent.Configuration(showsSubmitButton: false)
        let sut = OnlineBankingComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertTrue(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }
}
