//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class UPIComponentTests: XCTestCase {
    
    func test_init_withApps() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context
        )
        
        XCTAssertEqual(sut.currentSelectedItemIdentifier, nil)
    }
    
    func test_init_withoutApps() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )
        
        XCTAssertEqual(sut.currentSelectedItemIdentifier, UPIComponent.Constants.vpaFlowIdentifier)
    }

    func test_paymentMethodType_isUpi() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )

        XCTAssertEqual(sut.paymentMethod.type, .upi)
    }

    func test_shouldRequireModalPresentation() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )

        XCTAssertTrue(sut.requiresModalPresentation)
    }

    func test_requiresKeyboardInput() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )
        
        let securedViewController = try XCTUnwrap(sut.viewController as? SecuredViewController<FormViewController>)
        let childViewController = securedViewController.childViewController

        XCTAssertTrue(childViewController.requiresKeyboardInput)
    }

    func testSubmit_shouldCallPaymentDelegateDidSubmit() throws {
        // Given
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upi)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context
        )

        setupRootViewController(sut.viewController)

        let didSubmitExpectation = XCTestExpectation(description: "Expect delegate.didSubmit() to be called.")

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        delegateMock.onDidSubmit = { data, component in
            didSubmitExpectation.fulfill()
        }

        let vpaInputItem: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.virtualPaymentAddressInputItem"))
        self.populate(textItemView: vpaInputItem, with: "testvpa@icici")

        // When
        sut.submit()

        // Then
        wait(for: [didSubmitExpectation], timeout: 10)
        XCTAssertEqual(delegateMock.didSubmitCallsCount, 1)
    }

    func testValidateGivenValidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upi)
        let configuration = UPIComponent.Configuration(showsSubmitButton: false)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )

        let vpaInputItem: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.virtualPaymentAddressInputItem"))
        self.populate(textItemView: vpaInputItem, with: "testvpa@icici")

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertTrue(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

    func testValidateGivenInvalidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upi)
        let configuration = UPIComponent.Configuration(showsSubmitButton: false)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertFalse(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

}
