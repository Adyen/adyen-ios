//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class UPIComponentTests: XCTestCase {

    private var context: AdyenContext!
    private var paymentMethod: UPIPaymentMethod!
    private var style: FormComponentStyle!
    private var sut: UPIComponent!
    private var analyticsProviderMock: AnalyticsProviderMock!

    override func setUpWithError() throws {
        paymentMethod = try AdyenCoder.decode(upi)
        analyticsProviderMock = AnalyticsProviderMock()
        context = AdyenContext(apiContext: Dummy.apiContext, payment: nil, analyticsProvider: analyticsProviderMock)
        style = FormComponentStyle()
        sut = UPIComponent(paymentMethod: paymentMethod,
                           context: context,
                           configuration: UPIComponent.Configuration(style: style))
        getFormViewController().title = "Test title"
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        context = nil
        paymentMethod = nil
        style = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testComponent_ShouldPaymentMethodTypeBeUPI() throws {
        // Given
        let expectedPaymentMethodType: PaymentMethodType = .upi

        // Action
        let paymentMethodType = sut.paymentMethod.type

        // Assert
        XCTAssertEqual(paymentMethodType, expectedPaymentMethodType)
    }

    func testComponent_ShouldRequireModalPresentation() throws {
        // Assert
        XCTAssertTrue(sut.requiresModalPresentation)
    }

    func testRequiresKeyboardInput() {
        let childViewController = getFormViewController()

        XCTAssertTrue(childViewController.requiresKeyboardInput)
    }

    func testTitle() {
        // Assert
        XCTAssertEqual(getFormViewController().title, "Test title")
    }

    private func getFormViewController() -> FormViewController {
        (sut.viewController as! SecuredViewController<FormViewController>).childViewController
    }
}
