//
//  DokuComponentUITests.swift
//  AdyenUIHostUITests
//
//  Created by Neelam Sharma on 24/02/2023.
//  Copyright © 2023 Adyen. All rights reserved.
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
        let sut = DokuComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: config)

        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }

    func testSubmitForm() throws {
        let sut = DokuComponent(paymentMethod: paymentMethod,
                                context: context,
                                configuration: DokuComponent.Configuration())
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
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
            
            self.wait(for: .aMoment)
            self.assertViewControllerImage(matching: sut.viewController, named: "doku_flow")
            
            delegateExpectation.fulfill()
        }
        
        submitButton.sendActions(for: .touchUpInside)
        
        wait(for: [delegateExpectation], timeout: 2)
        
    }

    private enum DokuViewIdentifier {
        static let firstName = "AdyenComponents.DokuComponent.firstNameItem"
        static let lastName = "AdyenComponents.DokuComponent.lastNameItem"
        static let email = "AdyenComponents.DokuComponent.emailItem"
        static let payButton = "AdyenComponents.DokuComponent.payButtonItem.button"
    }

}
