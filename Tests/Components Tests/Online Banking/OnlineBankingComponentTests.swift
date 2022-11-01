//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import XCTest

class OnlineBankingComponentTests: XCTestCase {

    private var context: AdyenContext!
    private var paymentMethod: OnlineBankingPaymentMethod!
    private var style: FormComponentStyle!
    private var sut: OnlineBankingComponent!
    private var analyticsProviderMock: AnalyticsProviderMock!

    override func setUpWithError() throws {
        paymentMethod = try! Coder.decode(onlineBankingDictionary) as OnlineBankingPaymentMethod
        analyticsProviderMock = AnalyticsProviderMock()
        context = AdyenContext(apiContext: Dummy.apiContext, payment: nil, analyticsProvider: analyticsProviderMock)
        style = FormComponentStyle()
        sut = OnlineBankingComponent(paymentMethod: paymentMethod,
                                     context: context,
                                     configuration: OnlineBankingComponent.Configuration(style: style))
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

    func testComponent_ShouldPaymentMethodTypeBeOnlineBanking() throws {
        // Given
        let expectedPaymentMethodType: PaymentMethodType = .onlineBankingCZ

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
        let securedviewController = sut.viewController as! SecuredViewController
        let childViewController = securedviewController.childViewController as! FormViewController
        return childViewController
    }
}
