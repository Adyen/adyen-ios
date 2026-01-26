//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import PassKit
import XCTest

class PreApplePayComponentTests: XCTestCase {

    var analyticsProviderMock: AnalyticsProviderMock!
    let amount = Dummy.payment.amount
    var paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "test_name", brands: ["mc", "visa"])
    var context: AdyenContext!
    var paymentComponentDelegate: PaymentComponentDelegateMock!
    var sut: PreApplePayComponent!
    lazy var applePayPayment = Dummy.createTestApplePayPayment()

    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsProviderMock = AnalyticsProviderMock()
        analyticsProviderMock._checkoutAttemptId = "test_attemp_id"
        context = Dummy.context(with: analyticsProviderMock)
        paymentComponentDelegate = PaymentComponentDelegateMock()

        let configuration = ApplePayComponent.Configuration(
            payment: applePayPayment,
            merchantIdentifier: "test_id"
        )
        var applePayStyle = ApplePayStyle()
        applePayStyle.paymentButtonType = .inStore
        let preApplePayConfig = PreApplePayComponent.Configuration(style: applePayStyle)
        sut = try! PreApplePayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: preApplePayConfig,
            applePayConfiguration: configuration
        )
        sut.delegate = paymentComponentDelegate
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        context = nil
        paymentComponentDelegate = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testPreApplePay_givenBrandsIsEmpty_shouldThrowUserCannotMakePayment() throws {
        // Given
        let brands: [String]? = []
        let paymentMethod = ApplePayPaymentMethod(type: .applePay, name: "Apple Pay", brands: brands)
        let applePayConfiguration = ApplePayComponent.Configuration(
            payment: Dummy.createTestApplePayPayment(),
            merchantIdentifier: "test_id"
        )

        // When / Then
        XCTAssertThrowsError(
            try PreApplePayComponent(
                paymentMethod: paymentMethod,
                context: Dummy.context,
                configuration: .init(),
                applePayConfiguration: applePayConfiguration
            )
        ) { error in
            XCTAssertEqual(error as? ApplePayComponent.Error, .userCannotMakePayment)
        }
    }

    func testUIConfiguration() {
        let applePayStyle = ApplePayStyle(
            paymentButtonStyle: .whiteOutline,
            paymentButtonType: .donate,
            cornerRadius: 10,
            backgroundColor: .orange,
            hintLabel: .init(
                font: .boldSystemFont(ofSize: 16),
                color: .red,
                textAlignment: .center
            )
        )
        let model = PreApplePayView.Model(
            hint: applePayPayment.amount.formatted,
            style: applePayStyle
        )
        
        let view = PreApplePayView(model: model)
        let viewController = UIViewController()
        viewController.view = view
        
        setupRootViewController(viewController)
        
        let hintLabel: UILabel? = viewController.view.findView(by: "hintLabel")
        XCTAssertEqual(hintLabel?.text, model.hint)
        XCTAssertEqual(hintLabel?.font, model.style.hintLabel.font)
        XCTAssertEqual(hintLabel?.textColor, model.style.hintLabel.color)
        XCTAssertEqual(hintLabel?.textAlignment, model.style.hintLabel.textAlignment)
        
        XCTAssertEqual(viewController.view.backgroundColor, model.style.backgroundColor)
        
        let style = view.model.style
        
        XCTAssertEqual(style.cornerRadius, 10)
        XCTAssertEqual(style.paymentButtonStyle, .whiteOutline)
        XCTAssertEqual(style.paymentButtonType, .donate)
    }
    
    func testApplePayPresented() {
        let dismissExpectation = expectation(description: "Dismiss Expectation")
        
        setupRootViewController(sut.viewController)
        
        let presentationMock = PresentationDelegateMock()
        presentationMock.doPresent = { component in
            self.presentOnRoot(component.viewController)
        }
        presentationMock.doDismiss = { completion in completion?() }
        sut.presentationDelegate = presentationMock
        
        let applePayButton = self.sut.viewController.view.findView(by: "applePayButton") as? PKPaymentButton
        
        XCTAssertNotNil(applePayButton)
        
        applePayButton?.sendActions(for: .touchUpInside)
        
        wait(for: .milliseconds(300))
        
        XCTAssertTrue(UIApplication.shared.adyen.mainKeyWindow?.rootViewController?.presentedViewController is PKPaymentAuthorizationViewController)
        UIApplication.shared.adyen.mainKeyWindow?.rootViewController?.presentedViewController?.dismiss(animated: false, completion: nil)

        sut.finalizeIfNeeded(with: false) {
            dismissExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testHintLabelAmount() throws {
        presentOnRoot(sut.viewController)
        
        let hintLabel: UILabel = try XCTUnwrap(sut.viewController.view.findView(by: "hintLabel"))
        
        XCTAssertEqual(hintLabel.text, self.applePayPayment.amount.formatted)
    }

    func testSubmitWithAnalyticsEnabledShouldSetCheckoutAttemptIdInPaymentComponentData() throws {
        // Given
        let paymentMethodDetails = ApplePayDetails(
            paymentMethod: paymentMethod,
            token: "test_token",
            network: "test_network",
            billingContact: nil,
            shippingContact: nil,
            shippingMethod: nil
        )
        let paymentComponentData = PaymentComponentData(
            paymentMethodDetails: paymentMethodDetails,
            amount: nil,
            order: nil
        )
        
        // When
        let expectation = expectation(description: "didSubmit is called")

        // Then
        paymentComponentDelegate.onDidSubmit = { data, _ in
            let sdkData = data.paymentMethod.sdkData
            let sdkDataDecoded = self.decodeSDKData(from: sdkData)
            XCTAssertNotNil(sdkData)
            XCTAssertEqual("test_attemp_id", sdkDataDecoded?.analytics.checkoutAttemptId)
            expectation.fulfill()
        }
        
        sut.submit(data: paymentComponentData)
        
        waitForExpectations(timeout: 5)
    }
    
    private func decodeSDKData(from sdkDataString: String?) -> SDKData? {
        guard let sdkDataString,
              let sdkDataDecoded: SDKData = try? AdyenCoder.decodeBase64(sdkDataString) else {
            XCTFail("SDKData should be present and decodable")
            return nil
        }
        return sdkDataDecoded
    }
}
