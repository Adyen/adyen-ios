//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
class PayByBankUSComponentTests: XCTestCase {
    
    let context = Dummy.context
    let paymentMethod = PayByBankUSPaymentMethod(type: .payByBankAISDD, name: "Plaid")
    
    func test_initiatePaymentShouldCallPaymentComponentDelegateDidSubmit() throws {

        let sut = PayByBankUSComponent(
            paymentMethod: paymentMethod,
            context: context
        )

        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        sut.performSubmit()

        let arguments = try XCTUnwrap(delegate.didSubmitReceivedArguments)
        XCTAssertTrue(arguments.component === sut)
        let details = try XCTUnwrap(arguments.data.paymentMethod as? GenericPaymentDetails)
        XCTAssertEqual(details.type, .payByBankAISDD)
    }
    
    func test_viewControllerLifecycle() throws {
        
        // check the elements on the viewcontroller
        // check starting/stopping loading
        
        let sut = PayByBankUSComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        
        let urlProvider = LogoURLProvider(environment: context.apiContext.environment)
        
        let viewController = try XCTUnwrap(sut.viewController as? PayByBankUSComponent.ConfirmationViewController)
        viewController.loadViewIfNeeded()
        
        let logoNames = ["US-1", "US-2", "US-3", "US-4"]
        
        XCTAssertEqual(viewController.submitButton.title, localizedString(.payByBankAISDDSubmit, nil))
        XCTAssertEqual(viewController.titleLabel.text, "Plaid")
        XCTAssertEqual(viewController.subtitleLabel.text, localizedString(.payByBankAISDDDisclaimerHeader, nil))
        XCTAssertEqual(viewController.messageLabel.text, localizedString(.payByBankAISDDDisclaimerBody, nil))
        XCTAssertEqual(viewController.supportedBankLogosView.imageUrls, logoNames.map { urlProvider.logoURL(withName: $0) })
        
        XCTAssertFalse(viewController.submitButton.showsActivityIndicator)
        
        viewController.submitTapped()
        
        wait(until: viewController.submitButton, at: \.showsActivityIndicator, is: true)
        
        sut.stopLoading()
        
        wait(until: viewController.submitButton, at: \.showsActivityIndicator, is: false)
    }
}
