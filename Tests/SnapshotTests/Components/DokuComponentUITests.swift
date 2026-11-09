//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
final class DokuComponentUITests: XCTestCase {

    private var context: AdyenContext!
    private var paymentMethod: DokuPaymentMethod!
    private var style: FormComponentStyle!

    override func setUpWithError() throws {
        context = Dummy.context
        style = FormComponentStyle()
        paymentMethod = DokuPaymentMethod(type: .dokuAlfamart, name: "test_name")
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        context = nil
        paymentMethod = nil
        try super.tearDownWithError()
    }

    func testUIConfiguration() {
        // Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        // background color
        style.backgroundColor = .yellow

        // Text field
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

        submitButton.sendActions(for: .touchUpInside)

        let submitted = try XCTUnwrap(delegate.didSubmitReceivedArguments)
        XCTAssertEqual(delegate.didSubmitCallsCount, 1)
        XCTAssertTrue(submitted.component === sut)
        XCTAssertTrue(submitted.data.paymentMethod is DokuDetails)
        let details = try XCTUnwrap(submitted.data.paymentMethod as? DokuDetails)
        XCTAssertEqual(details.firstName, "Mohamed")
        XCTAssertEqual(details.lastName, "Smith")
        XCTAssertEqual(details.emailAddress, "mohamed.smith@domain.com")

        sut.stopLoading()
        XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
        XCTAssertEqual(sut.button.showsActivityIndicator, false)

        verifyViewControllerImage(matching: sut.viewController, named: "doku_flow")
    }

    func testSubmitShouldCallPaymentDelegateDidSubmit() throws {
        // Given
        let sut = DokuComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        let paymentDelegateMock = PaymentComponentDelegateMock()
        sut.delegate = paymentDelegateMock

        let firstNameView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.firstName))
        self.populate(textItemView: firstNameView, with: "Katrina")

        let lastNameView: FormTextInputItemView! = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.lastName))
        self.populate(textItemView: lastNameView, with: "Del Mar")

        let emailView: FormTextInputItemView = try XCTUnwrap(sut.viewController.view.findView(with: DokuViewIdentifier.email))
        self.populate(textItemView: emailView, with: "katrina.mar@mail.com")

        // When
        sut.performSubmit()

        // Then
        XCTAssertEqual(paymentDelegateMock.didSubmitCallsCount, 1)
    }

    private enum DokuViewIdentifier {
        static let firstName = "AdyenComponents.DokuComponent.firstNameItem"
        static let lastName = "AdyenComponents.DokuComponent.lastNameItem"
        static let email = "AdyenComponents.DokuComponent.emailItem"
        static let payButton = "AdyenComponents.DokuComponent.payButtonItem.button"
    }

}
