//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenCard
@testable import AdyenComponents
import AdyenDropIn
import XCTest

class GiftCardUITests: XCTestCase {
    
    func test_checkBalance_failure() throws {

        let partialPaymentDelegate = PartialPaymentDelegateMock()
        let publicKeyProvider = PublicKeyProviderMock()
        
        let sut = GiftCardComponent(
            partialPaymentMethodType: .giftCard(.init(type: .giftcard, name: "Giftcard", brand: "Giftcard")),
            context: Dummy.context,
            amount: .init(value: 1, currencyCode: "EUR"),
            publicKeyProvider: publicKeyProvider
        )
        sut.partialPaymentDelegate = partialPaymentDelegate
        sut.viewController.loadViewIfNeeded()
        
        let onCheckBalanceExpectation = expectation(description: "Expect partialPaymentDelegate.onCheckBalance to be called.")

        partialPaymentDelegate.onCheckBalance = { _, completion in
            completion(.failure(Dummy.error))
            onCheckBalanceExpectation.fulfill()
        }

        let securityCodeItemView = try sut.securityCodeItemView()
        securityCodeItemView.textField.text = "73737"
        securityCodeItemView.textField.sendActions(for: .editingChanged)
        
        let numberItemView = try sut.numberItemView()
        numberItemView.textField.text = "60643650100000000000"
        numberItemView.textField.sendActions(for: .editingChanged)
        
        try sut.payButtonItemViewButton().sendActions(for: .touchUpInside)

        let errorView = try sut.errorView()
        
        wait {
            errorView.isHidden == false
        }
        
        wait(for: [onCheckBalanceExpectation], timeout: 10)
        
        assertViewControllerImage(matching: sut.viewController, named: "GiftCardUITests.test_checkBalance_failure")
        
        XCTAssertEqual(errorView.messageLabel.text, localizedString(.errorUnknown, nil))
    }
}

// MARK: - Convenience

private extension GiftCardComponent {
    
    func errorView() throws -> FormErrorItemView {
        try XCTUnwrap(viewController.view.findView(with: "AdyenCard.GiftCardComponent.errorItem"))
    }

    func numberItemView() throws -> FormTextInputItemView {
        try XCTUnwrap(viewController.view.findView(with: "AdyenCard.GiftCardComponent.numberItem"))
    }

    func securityCodeItemView() throws -> FormTextInputItemView {
        try XCTUnwrap(viewController.view.findView(with: "AdyenCard.GiftCardComponent.securityCodeItem"))
    }
    
    func payButtonItemViewButton() throws -> UIControl {
        try XCTUnwrap(viewController.view.findView(with: "AdyenCard.GiftCardComponent.payButtonItem.button"))
    }
}
