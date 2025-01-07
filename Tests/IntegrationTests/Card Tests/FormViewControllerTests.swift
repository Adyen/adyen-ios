//
// Copyright (c) 2025 Adyen N.V.
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

        let cardNumberItem = FormCardNumberItem(cardTypeLogos: [])
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
}
