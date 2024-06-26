//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import AdyenDropIn
import XCTest

class UPIComponentUITests: XCTestCase {

    private lazy var paymentMethod: UPIPaymentMethod = .init(
        type: .upi,
        name: "upi",
        apps: upiApps
    )
    private var context: AdyenContext { Dummy.context }
    private var style: FormComponentStyle { FormComponentStyle() }
    private var upiApps: [Issuer] = [
        Issuer(identifier: "bhim", name: "BHIM"),
        Issuer(identifier: "gpay", name: "Google Pay"),
        Issuer(identifier: "phonepe", name: "PhonePe")
    ]

    override func setUpWithError() throws {
        try super.setUpWithError()
        BrowserInfo.cachedUserAgent = "some_value"
    }

    func testUIConfiguration() throws {
        var style = style
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
        
        self.wait(for: .aMoment)
    
        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration")
    }
    
    func testUIConfigurationForIndexOne() throws {
        var style = style
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
        
        let segmentedControl: UISegmentedControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.upiFlowSelectionSegmentedControlItem"))
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.sendActions(for: .valueChanged)
        
        self.wait(for: .aMoment)

        assertViewControllerImage(matching: sut.viewController, named: "UI_configuration_Index_One")
    }

    func testUIElementsForPayByAnyUPIAppFlowType() {
        // Assert
        let config = UPIComponent.Configuration(style: style)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
        
        assertViewControllerImage(matching: sut.viewController, named: "all_required_fields_exist")
    }

    func testUPIComponentDetailsForUPIIntentFlow() throws {
        // Given
        let config = UPIComponent.Configuration(style: style)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is UPIComponentDetails)
            let data = data.paymentMethod as! UPIComponentDetails
            XCTAssertEqual(data.virtualPaymentAddress, nil)
            XCTAssertEqual(data.type, "upi_intent")
            didSubmitExpectation.fulfill()
        }
        
        sut.upiAppsList.first?.selectionHandler?()
        wait(for: .aMoment)
        
        assertViewControllerImage(matching: sut.viewController, named: "upi_intent")

        let continueButton: UIControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.continueButton.button"))
        continueButton.sendActions(for: .touchUpInside)
    
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testUPIComponentDetailsForUPICollectFlow() throws {
        // Given
        let config = UPIComponent.Configuration(style: style)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
        
        sut.viewController.loadViewIfNeeded()

        let didSubmitExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock

        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is UPIComponentDetails)
            let data = data.paymentMethod as! UPIComponentDetails
            XCTAssertEqual(data.virtualPaymentAddress, "testvpa@icici")
            XCTAssertEqual(data.type, "upi_collect")
            
            didSubmitExpectation.fulfill()
        }

        let selectionHandler = try XCTUnwrap(sut.upiAppsList.last?.selectionHandler)
        selectionHandler()

        let virtualPaymentAddressItem: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.virtualPaymentAddressInputItem"))
        
        self.populate(textItemView: virtualPaymentAddressItem, with: "testvpa@icici")
        
        wait { virtualPaymentAddressItem.isHidden == false }
        wait(for: .aMoment) // Wait for the animation to finish
        
        self.assertViewControllerImage(matching: sut.viewController, named: "prefilled_vpa")
        
        let continueButton: UIControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.continueButton.button"))
        continueButton.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testUPIComponentDetailsForUPIQRCodeFlow() throws {
        // Given
        let config = UPIComponent.Configuration(style: style)
        let sut = UPIComponent(paymentMethod: paymentMethod,
                               context: context,
                               configuration: config)
        
        let segmentedControl: UISegmentedControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.upiFlowSelectionSegmentedControlItem"))
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.sendActions(for: .valueChanged)
        
        wait(for: .aMoment)
        
        let continueButton: SubmitButton = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.continueButton.button"))
        XCTAssertEqual(continueButton.title, localizedString(.QRCodeGenerateQRCode, nil))
        
        let dummyExpectation = XCTestExpectation(description: "Dummy Expectation")
        
        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        
        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is UPIComponentDetails)
            let data = data.paymentMethod as! UPIComponentDetails
            XCTAssertNotNil(data.type)
            XCTAssertEqual(data.type, "upi_qr")
            sut.stopLoadingIfNeeded()
            
            self.wait(for: .aMoment)
            
            self.assertViewControllerImage(matching: sut.viewController, named: "upi_qr_flow")
            dummyExpectation.fulfill()
        }
        
        continueButton.sendActions(for: .touchUpInside)
        
        wait(for: [dummyExpectation], timeout: 5)
    }

    func test_noAppSelectedSubmit_shouldShowError() throws {
        
        let config = UPIComponent.Configuration(style: style)
        let sut = UPIComponent(paymentMethod: paymentMethod,
                               context: context,
                               configuration: config)
        
        let errorItem = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.errorItem"))
        XCTAssertTrue(errorItem.isHidden)
        
        let continueButton: SubmitButton = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.continueButton.button"))
        
        // Tapping button with no apps selected - error should be shown
        
        continueButton.sendActions(for: .touchUpInside)
        wait { errorItem.isHidden == false }
        
        self.assertViewControllerImage(matching: sut.viewController, named: "upi_no_app_selected_submit")
        
        // Switching tabs - error should be reset/hidden
        
        let segmentedControl: UISegmentedControl = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.upiFlowSelectionSegmentedControlItem"))
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.sendActions(for: .valueChanged)
        
        wait { errorItem.isHidden == true }
        
        // Switching back to apps - error should still be hidden
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sendActions(for: .valueChanged)
        
        XCTAssertTrue(errorItem.isHidden)
        
        // Tapping button with no apps selected - error should be shown
        
        continueButton.sendActions(for: .touchUpInside)
        wait { errorItem.isHidden == false }
        
        let selectionHandler = try XCTUnwrap(sut.upiAppsList.last?.selectionHandler)
        selectionHandler()
        
        wait { errorItem.isHidden == true }
    }
}
