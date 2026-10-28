//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenDropIn
import XCTest

class ModalViewControllerTests: XCTestCase {
    private enum Constants {
        static let accessibilityFontSize: CGFloat = 64
        static let navigationBarHeight: CGFloat = 63
        static let compactSize = CGSize(width: 320, height: 800)
        static let regularSize = CGSize(width: 704, height: 800)
        static let additionalTopInset: CGFloat = 24
        static let longTitle = "Credit or debit card payment details"
        static let traitChangeTimeout: TimeInterval = 2
        static let traitChangeRetryInterval: DispatchTimeInterval = .milliseconds(10)
        static var separatorHeight: CGFloat {
            1.0 / UIScreen.main.scale
        }
    }
    
    var sut: ModalViewController!
    lazy var viewController: UIViewController = {
        let view = UIViewController(nibName: nil, bundle: nil)
        view.title = "ModalViewControllerTest"
        return view
    }()
    
    override func tearDown() {
        sut = nil
    }

    func testCustomStyle() {
        var style = NavigationStyle()
        style.separatorColor = .red
        style.backgroundColor = .brown

        loadAndRunTests(for: style) {
            XCTAssertEqual(self.sut.separator.backgroundColor, .red)
            XCTAssertEqual(self.sut.view.backgroundColor, .brown)
        }
    }

    func testNavigationBarHeightIncludesTopSafeAreaInset() {
        loadAndRunTests(for: NavigationStyle()) {
            self.sut.additionalSafeAreaInsets.top = 24
            self.sut.view.setNeedsLayout()
            self.sut.view.layoutIfNeeded()

            let separatorHeight = 1.0 / UIScreen.main.scale
            let expectedHeight = Constants.navigationBarHeight - separatorHeight + self.sut.view.safeAreaInsets.top
            XCTAssertEqual(self.sut.navBar.frame.height, expectedHeight, accuracy: 0.5)
        }
    }

    func testCustomNavigationBarHeightIgnoresTopSafeAreaInset() {
        loadAndRunTests(for: NavigationStyle(), navBarType: .custom(CustomNavigationBar())) {
            self.sut.additionalSafeAreaInsets.top = 24
            self.sut.view.setNeedsLayout()
            self.sut.view.layoutIfNeeded()

            let separatorHeight = 1.0 / UIScreen.main.scale
            XCTAssertEqual(self.sut.navBar.frame.height, Constants.navigationBarHeight - separatorHeight, accuracy: 0.5)
        }
    }

    func testNavigationBarHeightGrowsWithItsTitle() throws {
        loadAndRunTests(for: NavigationStyle()) {}
        let toolbar = try XCTUnwrap(sut.navBar as? ModalToolbar)
        let originalSize = sut.preferredContentSize
        toolbar.titleLabel.font = .systemFont(ofSize: Constants.accessibilityFontSize)
        sut.view.setNeedsLayout()
        sut.view.layoutIfNeeded()
        sut.view.layoutIfNeeded()

        XCTAssertGreaterThan(sut.navBar.frame.height - sut.view.safeAreaInsets.top, Constants.navigationBarHeight)
        XCTAssertGreaterThan(sut.preferredContentSize.height, originalSize.height)
    }

    func testNavigationBarHeightStaysDefaultAtDefaultTextSize() throws {
        try hostAtTextSize(.large)
        sut.view.frame = CGRect(origin: .zero, size: Constants.compactSize)
        sut.view.layoutIfNeeded()

        XCTAssertEqual(laidOutToolbarHeight(), Constants.navigationBarHeight - Constants.separatorHeight, accuracy: 0.5)
        XCTAssertEqual(sut.preferredContentSize.height, Constants.navigationBarHeight + Constants.separatorHeight, accuracy: 0.5)
    }

    func testNavigationBarHeightFollowsWidthAtAccessibilityTextSizes() throws {
        try hostAtTextSize(.accessibilityExtraExtraExtraLarge)

        sut.view.frame = CGRect(origin: .zero, size: Constants.compactSize)
        sut.view.layoutIfNeeded()
        let compactToolbarHeight = laidOutToolbarHeight()
        let compactPreferredHeight = sut.preferredContentSize.height

        sut.view.frame = CGRect(origin: .zero, size: Constants.regularSize)
        sut.view.layoutIfNeeded()
        let regularToolbarHeight = laidOutToolbarHeight()

        XCTAssertGreaterThan(compactToolbarHeight, Constants.navigationBarHeight)
        XCTAssertGreaterThan(compactToolbarHeight, regularToolbarHeight)
        XCTAssertEqual(compactPreferredHeight, compactToolbarHeight + 2 * Constants.separatorHeight, accuracy: 0.5)
        XCTAssertEqual(sut.preferredContentSize.height, regularToolbarHeight + 2 * Constants.separatorHeight, accuracy: 0.5)
    }

    func testPreferredContentSizeExcludesTopSafeAreaInsetAtAccessibilityTextSizes() throws {
        try hostAtTextSize(.accessibilityExtraExtraExtraLarge)
        sut.view.frame = CGRect(origin: .zero, size: Constants.compactSize)
        sut.view.layoutIfNeeded()
        let preferredHeight = sut.preferredContentSize.height
        let toolbarHeight = laidOutToolbarHeight()

        sut.additionalSafeAreaInsets.top = Constants.additionalTopInset
        sut.view.setNeedsLayout()
        sut.view.layoutIfNeeded()

        XCTAssertEqual(sut.preferredContentSize.height, preferredHeight, accuracy: 0.5)
        XCTAssertEqual(laidOutToolbarHeight(), toolbarHeight, accuracy: 0.5)
        XCTAssertEqual(sut.navBar.frame.height, toolbarHeight + sut.view.safeAreaInsets.top, accuracy: 0.5)
    }

    func testFormContentAlignsWithToolbar() throws {
        let formStyle = FormComponentStyle()
        let formController = FormViewController(scrollEnabled: true, style: formStyle, localizationParameters: nil)
        formController.title = "Cards"
        let numberItem = FormTextInputItem(style: formStyle.textField)
        numberItem.title = "Card number"
        formController.append(numberItem)
        formController.append(FormButtonItem(style: formStyle.mainButtonItem))
        formController.view.isUserInteractionEnabled = false
        let securedController = SecuredViewController(child: formController, style: formStyle)
        sut = ModalViewController(rootViewController: securedController, navBarType: .regular)
        sut.additionalSafeAreaInsets.right = 32
        setupRootViewController(sut)

        let toolbar = try XCTUnwrap(sut.navBar as? ModalToolbar)
        let scrollView = try XCTUnwrap(formController.view.subviews.first { $0 is UIScrollView } as? UIScrollView)
        let formView = try XCTUnwrap(scrollView.subviews.first { $0 is FormView } as? FormView)
        let stackView = try XCTUnwrap(formView.subviews.first { $0 is UIStackView } as? UIStackView)
        let numberView = try XCTUnwrap(stackView.arrangedSubviews.first as? FormTextInputItemView)
        let buttonView = try XCTUnwrap(stackView.arrangedSubviews.last as? FormButtonItemView)

        for size in [CGSize(width: 320, height: 640), CGSize(width: 704, height: 430)] {
            sut.view.frame = CGRect(origin: .zero, size: size)
            sut.view.layoutIfNeeded()
            let heading = toolbar.titleLabel.convert(toolbar.titleLabel.bounds, to: sut.view)
            let closeButton = toolbar.cancelButton.convert(toolbar.cancelButton.bounds, to: sut.view)
            let field = numberView.titleLabel.convert(numberView.titleLabel.bounds, to: sut.view)
            let payButton = buttonView.submitButton.convert(buttonView.submitButton.bounds, to: sut.view)

            XCTAssertEqual(field.minX, heading.minX, accuracy: 0.5)
            XCTAssertEqual(payButton.minX, heading.minX, accuracy: 0.5)
            XCTAssertEqual(payButton.maxX, closeButton.maxX, accuracy: 0.5)
        }
    }
    
    private func hostAtTextSize(_ category: UIContentSizeCategory) throws {
        viewController.title = Constants.longTitle
        sut = ModalViewController(rootViewController: viewController, navBarType: .regular)
        let parent = UIViewController()
        parent.addChild(sut)
        parent.view.addSubview(sut.view)
        sut.didMove(toParent: parent)
        setupRootViewController(parent)
        parent.setOverrideTraitCollection(UITraitCollection(preferredContentSizeCategory: category), forChild: sut)
        let toolbar = try XCTUnwrap(sut.navBar as? ModalToolbar)
        let expectsWrapping = category > .large
        wait(
            until: { (toolbar.titleLabel.numberOfLines == 0) == expectsWrapping },
            timeout: Constants.traitChangeTimeout,
            retryInterval: Constants.traitChangeRetryInterval
        )
    }

    private func laidOutToolbarHeight() -> CGFloat {
        sut.navBar.frame.height - sut.view.safeAreaInsets.top
    }

    fileprivate func loadAndRunTests(
        for style: NavigationStyle,
        navBarType: NavigationBarType = .regular,
        test: @escaping () -> Void
    ) {
        sut = ModalViewController(
            rootViewController: viewController,
            style: style,
            navBarType: navBarType
        )
        setupRootViewController(sut)
        
        sut.loadView()
        sut.viewDidLoad()
        
        wait(for: .milliseconds(300))
        
        test()
    }
}

private final class CustomNavigationBar: UIView, AnyNavigationBar {
    var onCancelHandler: (() -> Void)?
}
