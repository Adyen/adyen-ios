//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
import AdyenNetworking
@_spi(AdyenInternal) @testable import AdyenUI
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
            }.first
        )
        let formView = try XCTUnwrap(scrollView.subviews.filter { $0 is FormView }.first)
        let stackView = try XCTUnwrap(formView.subviews.filter { $0 is UIStackView }.first)
        let cardHolderItemView = try XCTUnwrap(stackView.subviews.last as? FormTextInputItemView)

        XCTAssertTrue(cardHolderItemView.isFirstResponder)
    }

    func test_scrollView_whenKeyboardFrameChanges_shouldUpdateBottomInsets() throws {
        let (sut, scrollView) = try makeSUT()

        postKeyboardFrameChange(to: makeKeyboardFrame(withHeight: 100))

        expectBottomInsets(in: scrollView, toBe: 100)

        postKeyboardFrameChange(to: .zero)

        expectBottomInsets(in: scrollView, toBe: .zero)
    }
}

private extension FormViewControllerTests {

    func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (sut: FormViewController, scrollView: UIScrollView) {
        let sut = FormViewController(scrollEnabled: true, style: FormComponentStyle(), localizationParameters: nil)

        sut.loadViewIfNeeded()

        let scrollView = try makeScrollView(from: sut, file: file, line: line)
        return (sut, scrollView)
    }

    func makeScrollView(
        from sut: FormViewController,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> UIScrollView {
        try XCTUnwrap(sut.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView, file: file, line: line)
    }

    func makeKeyboardFrame(withHeight height: CGFloat) -> CGRect {
        CGRect(
            x: UIScreen.main.bounds.minX,
            y: UIScreen.main.bounds.maxY - height,
            width: UIScreen.main.bounds.width,
            height: height
        )
    }

    func postKeyboardFrameChange(to frame: CGRect) {
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardFrameEndUserInfoKey: frame,
                UIResponder.keyboardAnimationDurationUserInfoKey: 0.25,
                UIResponder.keyboardAnimationCurveUserInfoKey: UIView.AnimationCurve.easeInOut.rawValue
            ]
        )
    }

    func expectBottomInsets(
        in scrollView: UIScrollView,
        toBe expectedInset: CGFloat,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        wait(
            until: {
                abs(scrollView.contentInset.bottom - expectedInset) < 0.1
                    && abs(scrollView.verticalScrollIndicatorInsets.bottom - expectedInset) < 0.1
            },
            timeout: 1.0,
            file: file,
            line: line
        )

        XCTAssertEqual(scrollView.contentInset.bottom, expectedInset, accuracy: 0.1, file: file, line: line)
        XCTAssertEqual(scrollView.verticalScrollIndicatorInsets.bottom, expectedInset, accuracy: 0.1, file: file, line: line)
    }
}
