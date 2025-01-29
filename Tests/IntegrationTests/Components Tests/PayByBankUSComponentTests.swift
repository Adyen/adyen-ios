//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

@testable @_spi(AdyenInternal) import Adyen
@testable @_spi(AdyenInternal) import AdyenComponents

class PayByBankUSComponentTests: XCTestCase {
    
    let context = Dummy.context
    let paymentMethod = PayByBankUSPaymentMethod(type: .payByBankAISDD, name: "Plaid")
    
    func test_initiatePaymentShouldCallPaymentComponentDelegateDidSubmit() throws {
        
        let sut = PayByBankUSComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        
        let delegateExpectation = expectation(description: "onDidSubmit is called once")
        
        let delegate = PaymentComponentDelegateMock()
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            let details = data.paymentMethod as! InstantPaymentDetails
            XCTAssertEqual(details.type, .payByBankAISDD)
            delegateExpectation.fulfill()
        }
        
        sut.delegate = delegate
        
        sut.initiatePayment()
        
        wait(for: [delegateExpectation], timeout: 1)
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
