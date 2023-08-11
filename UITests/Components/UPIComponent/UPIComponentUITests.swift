//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import AdyenDropIn
import XCTest

class UPIComponentUITests: XCTestCase {

    private var paymentMethod: UPIPaymentMethod!
    private var context: AdyenContext!
    private var style: FormComponentStyle!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = UPIPaymentMethod(type: .upi, name: "upi")
        context = Dummy.context
        style = FormComponentStyle()
        BrowserInfo.cachedUserAgent = "some_value"
    }

    override func tearDownWithError() throws {
        paymentMethod = nil
        context = nil
        style = nil
        try super.tearDownWithError()
    }

    func testUIConfiguration() throws {
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
    
        let config = UPIComponent.Configuration(style: style)
        let sut = UPIComponent(paymentMethod: paymentMethod,
                               context: context,
                               configuration: config)
    
        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }
    
    func testUIConfigurationForIndexOne() throws {
    
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
        
        /// segmentedControlStyle
        style.segmentedControlStyle.tintColor = .yellow
        style.segmentedControlStyle.backgroundColor = .blue
        style.segmentedControlStyle.textStyle.backgroundColor = .systemPink
        style.segmentedControlStyle.textStyle.font = .systemFont(ofSize: 10)
        style.segmentedControlStyle.textStyle.textAlignment = .center
        style.segmentedControlStyle.textStyle.color = .red
    
        let config = UPIComponent.Configuration(style: style)
        let sut = UPIComponent(paymentMethod: paymentMethod,
                               context: context,
                               configuration: config)
        sut.currentSelectedIndex = 1

        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration_Index_One")
    }

    func testUIElementsForUPICollectFlowType() {
        // Assert
        let config = UPIComponent.Configuration(style: style)
        let sut = UPIComponent(paymentMethod: paymentMethod,
                               context: context,
                               configuration: config)
        assertViewControllerImage(matching: sut.viewController, named: "all_required_fields_exist")
    }

    func testUPIComponentDetailsExists() {
        // Given
        let upiComponentDetails = UPIComponentDetails(type: "vpa", virtualPaymentAddress: "testvpa@icici")

        // Assert
        XCTAssertNotNil(upiComponentDetails)
    }

    func testUPIComponentDetailsForUPICollectFlow() throws {
        // Given
        let config = UPIComponent.Configuration(style: style)
        let sut = UPIComponent(paymentMethod: paymentMethod,
                               context: context,
                               configuration: config)
        sut.currentSelectedIndex = 0

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is UPIComponentDetails)
            let data = data.paymentMethod as! UPIComponentDetails
            XCTAssertEqual(data.virtualPaymentAddress, "testvpa@icici")
            XCTAssertNotNil(data.type)
            didSubmitExpectation.fulfill()
        }
        
        try setupRootViewController(sut.viewController)

        let virtualPaymentAddressItem: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.virtualPaymentAddressInputItem")
        self.populate(textItemView: virtualPaymentAddressItem, with: "testvpa@icici")

        assertViewControllerImage(matching: sut.viewController, named: "prefilled_vpa")

        let continueButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.continueButton.button")
        continueButton?.sendActions(for: .touchUpInside)
    
        waitForExpectations(timeout: 10, handler: nil)
    }
 
    func testUPIComponentDetailsForUPIQRCodeFlow() throws {
        // Given
        let config = UPIComponent.Configuration(style: style)
        let sut = UPIComponent(paymentMethod: paymentMethod,
                               context: context,
                               configuration: config)

        sut.didChangeSegmentedControlIndex(1)

        let continueButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.generateQRCodeButton.button")
        continueButton?.sendActions(for: .touchUpInside)
        
        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        
        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is UPIComponentDetails)
            let data = data.paymentMethod as! UPIComponentDetails
            XCTAssertNotNil(data.type)
            XCTAssertEqual(data.type, "upi_qr")
        }
        
        try setupRootViewController(sut.viewController)
        
        assertViewControllerImage(matching: sut.viewController, named: "upi_qr_flow")
    }

}
