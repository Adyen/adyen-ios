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
            let expectedHeight = 63.0 - separatorHeight + self.sut.view.safeAreaInsets.top
            XCTAssertEqual(self.sut.navBar.frame.height, expectedHeight, accuracy: 0.5)
        }
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
    
    fileprivate func loadAndRunTests(for style: NavigationStyle, test: @escaping () -> Void) {
        sut = ModalViewController(
            rootViewController: viewController,
            style: style,
            navBarType: .regular
        )
        setupRootViewController(sut)
        
        sut.loadView()
        sut.viewDidLoad()
        
        wait(for: .milliseconds(300))
        
        test()
    }
}
