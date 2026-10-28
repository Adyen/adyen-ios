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
    private enum Constants {
        static let traitChangeTimeout: TimeInterval = 2
        static let traitChangeRetryInterval: DispatchTimeInterval = .milliseconds(10)
    }

    func test_textSizeChange_growsAndReportsPreferredContentSize() {
        for scrollEnabled in [true, false] {
            let style = FormComponentStyle()
            let sut = FormViewController(scrollEnabled: scrollEnabled, style: style, localizationParameters: nil)
            let item = FormTextInputItem(style: style.textField)
            item.title = "Card number"
            sut.append(item)
            let container = PreferredContentSizeConsumerSpy()
            container.addChild(sut)
            container.view.addSubview(sut.view)
            sut.didMove(toParent: container)
            setupRootViewController(container)
            container.setOverrideTraitCollection(UITraitCollection(preferredContentSizeCategory: .large), forChild: sut)
            sut.view.layoutIfNeeded()
            // A non-scrolling form reports no intrinsic size, so its fitting size is measured instead.
            let contentHeight = { scrollEnabled ? sut.preferredContentSize.height : sut.view.adyen.minimalSize.height }
            let initialHeight = contentHeight()
            container.didUpdateCount = 0

            container.setOverrideTraitCollection(
                UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
                forChild: sut
            )
            wait(
                until: { container.didUpdateCount > 0 && contentHeight() > initialHeight },
                timeout: Constants.traitChangeTimeout,
                retryInterval: Constants.traitChangeRetryInterval
            )

            XCTAssertGreaterThan(container.didUpdateCount, 0)
            XCTAssertGreaterThan(contentHeight(), initialHeight)
        }
    }
    
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

    func test_formContentAlignsWithSafeAreaGutter() throws {
        for scrollEnabled in [true, false] {
            let style = FormComponentStyle()
            let sut = FormViewController(scrollEnabled: scrollEnabled, style: style, localizationParameters: nil)
            let numberItem = FormCardNumberItem(cardTypeLogos: [], scanCardHandler: nil)
            numberItem.title = "Card number"
            let expiryItem = FormTextInputItem(style: style.textField)
            expiryItem.title = "Expiry date"
            let securityCodeItem = FormTextInputItem(style: style.textField)
            securityCodeItem.title = "Security code"
            let toggleItem = FormToggleItem(style: style.toggle)
            toggleItem.title = "Remember for next time"
            let buttonItem = FormButtonItem(style: style.mainButtonItem)
            buttonItem.title = "Pay"

            sut.append(numberItem)
            sut.append(FormSplitItem(items: expiryItem, securityCodeItem, style: style.textField))
            sut.append(toggleItem)
            sut.append(buttonItem)
            sut.view.isUserInteractionEnabled = false
            sut.additionalSafeAreaInsets.right = 32
            setupRootViewController(sut)

            let contentView = try XCTUnwrap(sut.view.subviews.first { $0 is UIScrollView || $0 is FormView })
            let formView = try XCTUnwrap((contentView as? UIScrollView)?.subviews.first { $0 is FormView } ?? contentView as? FormView)
            let stackView = try XCTUnwrap(formView.subviews.first { $0 is UIStackView } as? UIStackView)
            let numberView = try XCTUnwrap(stackView.arrangedSubviews[0] as? FormCardNumberItemView)
            let splitView = try XCTUnwrap(stackView.arrangedSubviews[1] as? FormSplitItemView)
            let expiryView = try XCTUnwrap(splitView.childItemViews[0] as? FormTextInputItemView)
            let securityCodeView = try XCTUnwrap(splitView.childItemViews[1] as? FormTextInputItemView)
            let toggleView = try XCTUnwrap(stackView.arrangedSubviews[2] as? FormToggleItemView)
            let toggleStack = try XCTUnwrap(toggleView.subviews.first { $0 is UIStackView } as? UIStackView)
            let toggleLabel = try XCTUnwrap(toggleStack.arrangedSubviews.first as? UILabel)
            let buttonView = try XCTUnwrap(stackView.arrangedSubviews[3] as? FormButtonItemView)

            let expectedInset: CGFloat = scrollEnabled ? 16 : 8
            for size in [CGSize(width: 320, height: 640), CGSize(width: 704, height: 430)] {
                sut.view.frame = CGRect(origin: .zero, size: size)
                sut.view.layoutIfNeeded()
                let safeArea = sut.view.safeAreaLayoutGuide.layoutFrame
                let numberFrame = numberView.titleLabel.convert(numberView.titleLabel.bounds, to: sut.view)
                let expiryFrame = expiryView.titleLabel.convert(expiryView.titleLabel.bounds, to: sut.view)
                let securityCodeFrame = securityCodeView.titleLabel.convert(securityCodeView.titleLabel.bounds, to: sut.view)
                let toggleFrame = toggleLabel.convert(toggleLabel.bounds, to: sut.view)
                let buttonFrame = buttonView.submitButton.convert(buttonView.submitButton.bounds, to: sut.view)

                XCTAssertEqual(numberFrame.minX, safeArea.minX + expectedInset, accuracy: 0.5)
                XCTAssertEqual(expiryFrame.minX, numberFrame.minX, accuracy: 0.5)
                XCTAssertEqual(toggleFrame.minX, numberFrame.minX, accuracy: 0.5)
                XCTAssertEqual(buttonFrame.minX, numberFrame.minX, accuracy: 0.5)
                XCTAssertEqual(buttonFrame.maxX, safeArea.maxX - expectedInset, accuracy: 0.5)
                XCTAssertEqual(securityCodeFrame.minX - expiryFrame.maxX, 16, accuracy: 0.5)
                if let scrollView = contentView as? UIScrollView {
                    XCTAssertEqual(scrollView.contentSize.width, scrollView.bounds.width, accuracy: 0.5)
                }
            }
        }
    }
}

private final class PreferredContentSizeConsumerSpy: UIViewController, PreferredContentSizeConsumer {
    var didUpdateCount = 0

    func willUpdatePreferredContentSize() {}

    func didUpdatePreferredContentSize() {
        didUpdateCount += 1
    }
}
