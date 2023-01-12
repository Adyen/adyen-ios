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

    private var paymentMethod: UPIComponentPaymentMethod!
    private var context: AdyenContext!
    private var style: FormComponentStyle!
    private var sut: UPIComponent!
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = try! Coder.decode(upi) as UPIComponentPaymentMethod
        context = AdyenContext(apiContext: Dummy.apiContext, payment: nil)
        style = FormComponentStyle()
        sut = UPIComponent(paymentMethod: paymentMethod,
                           context: context,
                           configuration: UPIComponent.Configuration(style: style))
        BrowserInfo.cachedUserAgent = "some_value"
    }

    override func tearDownWithError() throws {
        paymentMethod = nil
        context = nil
        style = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testUIElementsForUPICollectFlowType() {
        // Assert
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.instructionsLabelItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.upiFlowSelectionSegmentedControlItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.virtualPaymentAddressInputItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.continueButton"))
    }

    func testPressContinueButton() {
        // Given

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        // Then
        let button: SubmitButton! = sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.continueButton.button")
        button.sendActions(for: .touchUpInside)

        let didContinueExpectation = XCTestExpectation(description: "Dummy Expectation")
        delegate.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === self.sut)
            let details = data.paymentMethod as! UPIComponentDetails
            XCTAssertEqual(details.type, "upi_collect")
            self.sut.stopLoadingIfNeeded()
            didContinueExpectation.fulfill()
        }
        delegate.onDidFail = { _, _ in
            XCTFail("delegate.didFail() should never be called.")
        }
        wait(for: .milliseconds(300))
    }

    func testContinueButtonLoading() {
        // Given
        UIApplication.shared.mainKeyWindow?.rootViewController = sut.viewController

        // Then
        let button: SubmitButton! = sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.continueButton.button")

        // Then
        self.sut.stopLoading()

        // Assert
        XCTAssertFalse(button.showsActivityIndicator)
    }

}
