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
    private var sut: UPIComponent!

    override func setUpWithError() throws {
        try super.setUpWithError()
        paymentMethod = try! Coder.decode(upi) as UPIPaymentMethod
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

    func testStopLoading() {
        // Given
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        wait(for: .milliseconds(300))

        //Assert
        XCTAssertFalse(sut.continueButton.showsActivityIndicator)

        // Given
        sut.continueButton.showsActivityIndicator = true
        sut.stopLoadingIfNeeded()

        //Assert
        XCTAssertFalse(sut.continueButton.showsActivityIndicator)
    }

    func testChangeSelectedSegmentControlIndex() {
        // Given
        sut.upiFlowSelectionItem.selectionHandler?(1)

        // Assert
        XCTAssertTrue(sut.currentSelectedIndex == 1)
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.instructionsLabelItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.upiFlowSelectionSegmentedControlItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.qrCodeGenerationImageItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.generateQRCodeLabelContainerItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.generateQRCodeButton"))

    }

    func testDidChangeSegmentedControlIndexToOne() {
        // Given
        sut.currentSelectedIndex = 0
        sut.didChangeSegmentedControlIndex(1)

        // Assert
        XCTAssertTrue(sut.currentSelectedIndex == 1)
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.instructionsLabelItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.upiFlowSelectionSegmentedControlItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.qrCodeGenerationImageItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.generateQRCodeLabelContainerItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.generateQRCodeButton"))
        XCTAssertTrue(UPIFlowType(rawValue: sut.currentSelectedIndex) == .some(.qrCode))
    }

    func testDidChangeSegmentedControlIndexToZero() {
        // Given
        sut.currentSelectedIndex = 1
        sut.didChangeSegmentedControlIndex(0)

        // Assert
        XCTAssertTrue(sut.currentSelectedIndex == 0)
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.instructionsLabelItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.upiFlowSelectionSegmentedControlItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.virtualPaymentAddressInputItem"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.continueButton"))
        XCTAssertTrue(UPIFlowType(rawValue: sut.currentSelectedIndex) == .some(.vpa))
    }

    func testUPIComponentDetailsExists() {
        // Given
        let upiComponentDetails = UPIComponentDetails(type: "vpa", virtualPaymentAddress: "testvpa@icici")

        // Assert
        XCTAssertNotNil(upiComponentDetails)
    }

    func testUPIComponentDetails() {
        // Given
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController

        let expectation = XCTestExpectation(description: "Dummy Expectation")

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        delegateMock.onDidSubmit = { data, component in
            // Assert
            XCTAssertTrue(component === self.sut)
            XCTAssertTrue(data.paymentMethod is UPIComponentDetails)
            let data = data.paymentMethod as! UPIComponentDetails
            XCTAssertEqual(data.virtualPaymentAddress, "testvpa@icici")
            XCTAssertNotNil(data.type)
            expectation.fulfill()
        }
        delegateMock.onDidFail = { _, _ in
            XCTFail("delegate.didFail() should never be called.")
        }

        wait(for: .milliseconds(300))

        let virtualPaymentAddressItem: FormTextItemView<FormTextInputItem>? = sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.virtualPaymentAddressInputItem")
        let continueButton: UIControl? = sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.continueButton.button")

        self.populate(textItemView: virtualPaymentAddressItem, with: "testvpa@icici")

        continueButton?.sendActions(for: .touchUpInside)

        wait(for: [expectation], timeout: 5)
    }

}
