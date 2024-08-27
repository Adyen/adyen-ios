//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
@testable @_spi(AdyenInternal) import AdyenTwint
import XCTest

class TwintComponentTests: XCTestCase {

    private var paymentMethod: TwintPaymentMethod!
    private var delegate: PaymentComponentDelegateMock!
    private var sut: TwintComponent!
    private var context: AdyenContext!

    override func setUp() {
        super.setUp()
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        context = Dummy.context

        delegate = PaymentComponentDelegateMock()
        paymentMethod = TwintPaymentMethod(type: .twint, name: "twint")
        sut = TwintComponent(paymentMethod: paymentMethod,
                             context: context)
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        context = nil
        paymentMethod = nil
        delegate = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testCustomPaymentData() throws {
        let delegateExpectation = expectation(description: "expect delegate to be called.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === self.sut)
            let details = data.paymentMethod as! TwintDetails
            XCTAssertEqual(details.type, .twint)
            XCTAssertEqual(details.subType, "sdk")
            delegateExpectation.fulfill()
        }

        sut.initiatePayment()

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testViewDidLoadWhenStorePaymentMethodFieldIsShownShouldSendInitialCall() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)

        let configuration = TwintComponentConfiguration(showsStorePaymentMethodField: true)
        sut = TwintComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        // When
        sut.viewDidLoad(viewController: sut.viewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)
    }

    func testViewDidLoadWhenStorePaymentMethodFieldIsNotShownShouldNotSendInitialCall() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)

        let configuration = TwintComponentConfiguration(showsStorePaymentMethodField: false)
        sut = TwintComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )

        let paymentMethods = PaymentMethods(regular: [paymentMethod], stored: [])
        let dropInComponent = DropInComponent(paymentMethods: paymentMethods, context: context)
        setupRootViewController(dropInComponent.viewController)
        analyticsProviderMock.initialEventCallsCount = 0

        // When
        dropInComponent.didSelect(sut)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 0)
    }

    // MARK: - Private

    private var paymentComponentData: PaymentComponentData {
        let details = TwintDetails(type: paymentMethod,
                                   subType: "sdk")
        return PaymentComponentData(paymentMethodDetails: details,
                                    amount: context.payment?.amount,
                                    order: nil)
    }

}
