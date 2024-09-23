//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

final class DokuComponentUITests: XCTestCase {

    private var context: AdyenContext!
    private var paymentMethod: DokuPaymentMethod!
    private var payment: Payment!
    private var style: FormComponentStyle!

    override func setUpWithError() throws {
        context = Dummy.context
        style = FormComponentStyle()
        paymentMethod = DokuPaymentMethod(type: .dokuAlfamart, name: "test_name")
        payment = Payment(amount: Amount(value: 2, currencyCode: "IDR"), countryCode: "ID")
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        context = nil
        paymentMethod = nil
        payment = nil
        try super.tearDownWithError()
    }

    func testUIConfiguration() {
        /// Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        /// background color
        style.backgroundColor = .yellow

        /// Text field
        style.textField.text.color = .brown
        style.textField.text.font = .systemFont(ofSize: 13)
        style.textField.text.textAlignment = .right

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .yellow
        style.textField.title.font = .systemFont(ofSize: 20)
        style.textField.title.textAlignment = .center
        style.textField.backgroundColor = .red

        let config = DokuComponent.Configuration(style: style)
        let sut = DokuComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }

    func testSubmitForm() throws {
        let sut = DokuComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: DokuComponent.Configuration()
        )
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let submitButton: UIControl = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.payButton))

        let firstNameView: FormTextInputItemView! = sut.viewController.view.findView(with: DokuViewIdentifier.firstName)
        self.populate(textItemView: firstNameView, with: "Mohamed")

        let lastNameView: FormTextInputItemView! = sut.viewController.view.findView(with: DokuViewIdentifier.lastName)
        self.populate(textItemView: lastNameView, with: "Smith")

        let emailView: FormTextInputItemView! = sut.viewController.view.findView(with: DokuViewIdentifier.email)
        self.populate(textItemView: emailView, with: "mohamed.smith@domain.com")

        let delegateExpectation = XCTestExpectation(description: "Dummy Expectation")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is DokuDetails)
            let data = data.paymentMethod as! DokuDetails
            XCTAssertEqual(data.firstName, "Mohamed")
            XCTAssertEqual(data.lastName, "Smith")
            XCTAssertEqual(data.emailAddress, "mohamed.smith@domain.com")
            
            sut.stopLoadingIfNeeded()
            delegateExpectation.fulfill()
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
            
            self.verifyViewControllerImage(matching: sut.viewController, named: "doku_flow")

            delegateExpectation.fulfill()
        }
        
        submitButton.sendActions(for: .touchUpInside)

        wait(for: [delegateExpectation], timeout: 60)
    }

    func testSubmitWithDefaultSubmitButtonHiddenShouldCallPaymentDelegateDidSubmit() throws {
        // Given
        let configuration = AbstractPersonalInformationComponent.Configuration(showsSubmitButton: false)
        let sut = DokuComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentDelegateMock = PaymentComponentDelegateMock()
        sut.delegate = paymentDelegateMock

        let firstNameView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.firstName))
        self.populate(textItemView: firstNameView, with: "Katrina")

        let lastNameView: FormTextInputItemView! = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.lastName))
        self.populate(textItemView: lastNameView, with: "Del Mar")

        let emailView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.email))
        self.populate(textItemView: emailView, with: "katrina.mar@mail.com")

        let didSubmitExpectation = expectation(description: "didSubmitExpectation")
        paymentDelegateMock.onDidSubmit = { _, _ in
            didSubmitExpectation.fulfill()
        }

        // When
        sut.submit()

        // Then
        waitForExpectations(timeout: 10)
        XCTAssertEqual(paymentDelegateMock.didSubmitCallsCount, 1)
    }

    func testSubmitWithDefaultSubmitButtonShownShouldNotCallPaymentDelegateDidSubmit() throws {
        // Given
        let configuration = AbstractPersonalInformationComponent.Configuration(showsSubmitButton: true)
        let sut = DokuComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentDelegateMock = PaymentComponentDelegateMock()
        sut.delegate = paymentDelegateMock

        // When
        sut.submit()

        // Then
        XCTAssertEqual(paymentDelegateMock.didSubmitCallsCount, 0)
    }
    
    func testValidateWitValidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let configuration = AbstractPersonalInformationComponent.Configuration(showsSubmitButton: false)
        let sut = DokuComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentDelegateMock = PaymentComponentDelegateMock()
        sut.delegate = paymentDelegateMock

        let firstNameView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.firstName))
        self.populate(textItemView: firstNameView, with: "Katrina")

        let lastNameView: FormTextInputItemView! = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.lastName))
        self.populate(textItemView: lastNameView, with: "Del Mar")

        let emailView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.email))
        self.populate(textItemView: emailView, with: "katrina.mar@mail.com")

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertTrue(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

    func testValidateWitInvalidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let configuration = AbstractPersonalInformationComponent.Configuration(showsSubmitButton: false)
        let sut = DokuComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentDelegateMock = PaymentComponentDelegateMock()
        sut.delegate = paymentDelegateMock

        let firstNameView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.firstName))
        self.populate(textItemView: firstNameView, with: "Katrina")

        let lastNameView: FormTextInputItemView! = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.lastName))
        self.populate(textItemView: lastNameView, with: "Del Mar")

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertFalse(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

    private enum DokuViewIdentifier {
        static let firstName = "AdyenComponents.DokuComponent.firstNameItem"
        static let lastName = "AdyenComponents.DokuComponent.lastNameItem"
        static let email = "AdyenComponents.DokuComponent.emailItem"
        static let payButton = "AdyenComponents.DokuComponent.payButtonItem.button"
    }

}
