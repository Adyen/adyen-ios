//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import AdyenDropIn
import XCTest

final class BoletoComponentUITests: XCTestCase {

    private var paymentMethod: BoletoPaymentMethod!
    private var context: AdyenContext!
    private var style: FormComponentStyle!

    override func setUpWithError() throws {
        paymentMethod = BoletoPaymentMethod(type: .boleto, name: "Boleto Bancario")
        context = AdyenContext(apiContext: Dummy.apiContext, payment: Dummy.payment, analyticsProvider: AnalyticsProviderMock())
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        context = nil
        try super.tearDownWithError()
    }

    func testUIConfiguration() {
        style = FormComponentStyle()

        let textStyle = TextStyle(
            font: .preferredFont(forTextStyle: .body),
            color: .brown,
            textAlignment: .natural
        )

        let imageStyle = ImageStyle(
            borderColor: .cyan,
            borderWidth: 10.0,
            cornerRadius: 10.0,
            clipsToBounds: true,
            contentMode: .left
        )

        style.backgroundColor = .blue

        style.sectionHeader = TextStyle(
            font: .systemFont(ofSize: 20, weight: .semibold),
            color: .darkGray,
            textAlignment: .left
        )

        style.textField = FormTextItemStyle(
            title: textStyle,
            text: textStyle,
            placeholderText: textStyle,
            icon: imageStyle
        )

        var switchStyle = FormToggleItemStyle(title: textStyle)
        switchStyle.tintColor = UIColor.red
        switchStyle.separatorColor = UIColor.yellow
        switchStyle.backgroundColor = UIColor.blue

        style.toggle = switchStyle

        style.hintLabel = textStyle

        style.mainButtonItem = FormButtonItemStyle(
            button: ButtonStyle(title: textStyle, cornerRadius: 25.0, background: .gray),
            background: .magenta
        )

        style.secondaryButtonItem = FormButtonItemStyle(
            button: ButtonStyle(title: textStyle, cornerRadius: 25.0, background: .gray),
            background: .magenta
        )

        let sut = BoletoComponent(paymentMethod: paymentMethod,
                                  context: context,
                                  configuration: Dummy.getConfiguration(showEmailAddress: true))

        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }

    func testPaymentDataProvided() {
        let mockInformation = Dummy.dummyFullPrefilledInformation
        let mockConfiguration = Dummy.getConfiguration(with: mockInformation, showEmailAddress: true)
        let mockDelegate = PaymentComponentDelegateMock()

        let sut = BoletoComponent(paymentMethod: paymentMethod,
                                  context: context,
                                  configuration: mockConfiguration)
        sut.delegate = mockDelegate

        let dummyExpectation = XCTestExpectation(description: "Dummy Expectation")

        let submitButton: SubmitButton? = sut.viewController.view.findView(by: "payButtonItem.button") as? SubmitButton
        submitButton?.sendActions(for: .touchUpInside)

        mockDelegate.onDidSubmit = { paymentData, paymentComponent in
            let boletoDetails = paymentData.paymentMethod as? BoletoDetails
            XCTAssertNotNil(boletoDetails)
            
            XCTAssertEqual(boletoDetails?.shopperName, mockInformation.shopperName)
            XCTAssertEqual(boletoDetails?.socialSecurityNumber, mockInformation.socialSecurityNumber)
            XCTAssertEqual(boletoDetails?.emailAddress, mockInformation.emailAddress)
            XCTAssertEqual(boletoDetails?.billingAddress, mockInformation.billingAddress)
            XCTAssertEqual(boletoDetails?.type, sut.boletoPaymentMethod.type)
            XCTAssertNil(boletoDetails?.telephoneNumber)

            dummyExpectation.fulfill()
        }

        wait(for: .aMoment)
        assertViewControllerImage(matching: sut.viewController, named: "boleto_flow")
    }
    
    func testPaymentDataProvidedNoEmail() {
        var mockInformation = Dummy.dummyFullPrefilledInformation
        mockInformation.emailAddress = nil
        let mockConfiguration = Dummy.getConfiguration(with: mockInformation, showEmailAddress: true)
        let mockDelegate = PaymentComponentDelegateMock()
        let sut = BoletoComponent(paymentMethod: paymentMethod,
                                  context: context,
                                  configuration: mockConfiguration)
        sut.delegate = mockDelegate
        let dummyExpectation = XCTestExpectation(description: "Dummy Expectation")

        let submitButton: SubmitButton? = sut.viewController.view.findView(by: "payButtonItem.button") as? SubmitButton

        submitButton?.sendActions(for: .touchUpInside)

        mockDelegate.onDidSubmit = { paymentData, paymentComponent in
            XCTAssertTrue(paymentComponent === sut)

            let boletoDetails = paymentData.paymentMethod as? BoletoDetails
            XCTAssertNotNil(boletoDetails)

            XCTAssertNil(boletoDetails?.emailAddress)

            dummyExpectation.fulfill()
        }

        wait(for: .aMoment)
        assertViewControllerImage(matching: sut.viewController, named: "boleto_flow")
    }
}
