//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import AdyenDropIn
import XCTest

class OnlineBankingComponentUITests: XCTestCase {

    private var paymentMethod: OnlineBankingPaymentMethod!
    private var context: AdyenContext!
    private var style: FormComponentStyle!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = try! Coder.decode(onlineBankingDictionary) as OnlineBankingPaymentMethod
        context = AdyenContext(apiContext: Dummy.apiContext, payment: nil)
        style = FormComponentStyle()
    }

    override func tearDownWithError() throws {
        paymentMethod = nil
        context = nil
        style = nil
        try super.tearDownWithError()
    }

    func testUIElements() {
        style.backgroundColor = .green

        /// Footer
        style.mainButtonItem.button.title.color = .white
        style.mainButtonItem.button.title.backgroundColor = .red
        style.mainButtonItem.button.title.textAlignment = .center
        style.mainButtonItem.button.title.font = .systemFont(ofSize: 22)
        style.mainButtonItem.button.backgroundColor = .red
        style.mainButtonItem.backgroundColor = .brown

        /// Text field
        style.textField.text.color = .yellow
        style.textField.text.font = .systemFont(ofSize: 5)
        style.textField.text.textAlignment = .center
        style.textField.placeholderText = TextStyle(font: .preferredFont(forTextStyle: .headline),
                                                    color: .systemOrange,
                                                    textAlignment: .center)

        style.textField.title.backgroundColor = .blue
        style.textField.title.color = .green
        style.textField.title.font = .systemFont(ofSize: 18)
        style.textField.title.textAlignment = .left
        style.textField.backgroundColor = .blue

        let config = OnlineBankingComponent.Configuration(style: style)
        let  sut = OnlineBankingComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: config)
        
        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }

    func testPressContinueButton() {
        // Given
        let config = OnlineBankingComponent.Configuration(style: style)
        let  sut = OnlineBankingComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: config)
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        // Then
        let button: SubmitButton! = sut.viewController.view.findView(with: "AdyenComponents.OnlineBankingComponent.continueButton.button")
        button.sendActions(for: .touchUpInside)

        let didContnueExpectation = XCTestExpectation(description: "Dummy Expectation")

        delegate.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            let details = data.paymentMethod as! OnlineBankingDetails
            XCTAssertEqual(details.type, .onlineBankingCZ)
            XCTAssertEqual(details.issuer, "jp")
            sut.stopLoadingIfNeeded()
            didContnueExpectation.fulfill()
        }
        wait(for: .milliseconds(300))
        assertViewControllerImage(matching: sut.viewController, named: "online_banking_flow")
    }

    func testContinueButtonLoading() {
        // Given
        let config = OnlineBankingComponent.Configuration(style: style)
        let  sut = OnlineBankingComponent(paymentMethod: paymentMethod,
                                          context: context,
                                          configuration: config)

        UIApplication.shared.mainKeyWindow?.rootViewController = sut.viewController
       
        let button: SubmitButton! = sut.viewController.view.findView(with: "AdyenComponents.OnlineBankingComponent.continueButton.button")

        // start loading
        button.showsActivityIndicator = true
        assertViewHeirarchy(matching: sut.viewController, named: "initial_state")

        // stop loading
        sut.stopLoading()
        button.showsActivityIndicator = false
        assertViewHeirarchy(matching: sut.viewController, named: "stopped_loading")
    }

}
