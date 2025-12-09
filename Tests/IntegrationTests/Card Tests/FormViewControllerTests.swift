//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import AdyenNetworking
import XCTest

class FormViewControllerTests: XCTestCase {
    
    func test_moving_firstResponders() throws {
        
        let style = FormComponentStyle()
        
        let formViewController = FormViewController(scrollEnabled: true, style: style, localizationParameters: nil)

        let cardNumberItem = FormCardNumberItem(cardTypeLogos: [], scanCardHandler: nil)
        let securityCodeItem = FormCardSecurityCodeItem(style: style.textField)
        
        formViewController.append(cardNumberItem)
        formViewController.append(securityCodeItem)
        
        setupRootViewController(formViewController)

        let scrollView = try XCTUnwrap(formViewController.view.subviews.filter { $0 is UIScrollView }.first)
        let formView = try XCTUnwrap(scrollView.subviews.filter { $0 is FormView }.first)
        let stackView = try XCTUnwrap(formView.subviews.filter { $0 is UIStackView }.first)
        let cardNumberItemView = try XCTUnwrap(stackView.subviews.first as? FormCardNumberItemView)
        let securityCodeItemView = try XCTUnwrap(stackView.subviews.last as? FormCardSecurityCodeItemView)
        
        cardNumberItemView.becomeFirstResponder()
        XCTAssertTrue(cardNumberItemView.isFirstResponder)
        
        formViewController.didReachMaximumLength(in: cardNumberItemView)
        
        XCTAssertFalse(cardNumberItemView.isFirstResponder)
        XCTAssertTrue(securityCodeItemView.isFirstResponder)
    }

    func test_focusNextInputField() throws {
        // Given
        let style = FormComponentStyle()

        let sut = FormViewController(
            scrollEnabled: true,
            style: style,
            localizationParameters: nil
        )

        let cardNumberItem = FormCardNumberItem(cardTypeLogos: [], scanCardHandler: nil)
        cardNumberItem.setCardNumber("4111 1111 1111 1111")
        let securityCodeItem = FormCardSecurityCodeItem(style: style.textField)
        securityCodeItem.value = "737"
        let cardHolderItem = FormTextInputItem(style: style.textField)

        sut.append(cardNumberItem)
        sut.append(securityCodeItem)
        sut.append(cardHolderItem)

        setupRootViewController(sut)

        // When
        sut.focusNextInputField()

        // Then
        let scrollView = try XCTUnwrap(
            sut.view.subviews.filter { $0 is UIScrollView
            }.first)
        let formView = try XCTUnwrap(scrollView.subviews.filter { $0 is FormView }.first)
        let stackView = try XCTUnwrap(formView.subviews.filter { $0 is UIStackView }.first)
        let cardHolderItemView = try XCTUnwrap(stackView.subviews.last as? FormTextInputItemView)

        XCTAssertTrue(cardHolderItemView.isFirstResponder)
    }
}
