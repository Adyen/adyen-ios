//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_documentation(visibility: internal) @testable import Adyen
@testable import AdyenComponents
import AdyenDropIn
import XCTest

final class MBWayComponentUITests: XCTestCase {

    private var paymentMethod: MBWayPaymentMethod!
    private var context: AdyenContext!
    private var style: FormComponentStyle!
    private var payment: Payment!

    override func setUpWithError() throws {
        context = Dummy.context
        paymentMethod = MBWayPaymentMethod(type: .mbWay, name: "test_name")
        payment = Payment(amount: Amount(value: 2, currencyCode: "EUR"), countryCode: "DE")
        style = FormComponentStyle()
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
        style.backgroundColor = .red

        /// Text field
        style.textField.text.color = .red
        style.textField.text.font = .systemFont(ofSize: 13)
        style.textField.text.textAlignment = .right

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .yellow
        style.textField.title.font = .systemFont(ofSize: 20)
        style.textField.title.textAlignment = .center
        style.textField.backgroundColor = .red
        
        let config = MBWayComponent.Configuration(style: style)
        let sut = MBWayComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 configuration: config)

        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }

    func testSubmitForm() throws {
        let sut = MBWayComponent(paymentMethod: paymentMethod, context: context)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let submitButton: UIControl? = sut.viewController.view.findView(with: MBWayViewIdentifier.payButton)

        let phoneNumberView: FormPhoneNumberItemView! = sut.viewController.view.findView(with: MBWayViewIdentifier.phone)
        self.populate(textItemView: phoneNumberView, with: "1233456789")

        let delegateExpectation = XCTestExpectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is MBWayDetails)
            let data = data.paymentMethod as! MBWayDetails
            XCTAssertEqual(data.telephoneNumber, "+3511233456789")

            sut.stopLoadingIfNeeded()
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
            
            self.verifyViewControllerImage(matching: sut.viewController, named: "mbway_flow")
            delegateExpectation.fulfill()
        }
        
        submitButton?.sendActions(for: .touchUpInside)
        
        wait(for: [delegateExpectation], timeout: 60)
    }

    // MARK: - Private

    private enum MBWayViewIdentifier {
        static let phone = "AdyenComponents.MBWayComponent.phoneNumberItem"
        static let payButton = "AdyenComponents.MBWayComponent.payButtonItem.button"
    }
}
