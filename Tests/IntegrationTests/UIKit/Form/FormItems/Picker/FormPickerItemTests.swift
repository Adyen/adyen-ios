//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import UIKit
import XCTest

class FormPickerItemTests: XCTestCase {
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    // TODO: FIX testPresentation test
//    func testPresentation() throws {
//
//        let presentViewControllerExpectation = expectation(description: "presenter.presentViewController was called")
//        let dismissViewControllerExpectation = expectation(description: "presenter.dismissViewController was called")
//
//        var presentedViewController: FormPickerSearchViewController<FormPickerElement>?
//
//        let mockPresenter = PresenterMock { viewController, animated in
//            presentedViewController = viewController as? FormPickerSearchViewController<FormPickerElement>
//            presentViewControllerExpectation.fulfill()
//        } dismiss: { animated in
//            dismissViewControllerExpectation.fulfill()
//        }
//
//        let formPickerItem = FormPickerItem(
//            preselectedValue: nil,
//            selectableValues: [FormPickerElement(identifier: "Identifier", title: "Title", subtitle: "Subtitle")],
//            title: "",
//            placeholder: "",
//            style: .init(),
//            presenter: mockPresenter
//        )
//
//        // Setting up formPickerItem
//        _ = FormPickerItemView(item: formPickerItem)
//
//        formPickerItem.selectionHandler()
//
//        wait(for: [presentViewControllerExpectation], timeout: 10)
//
//        setupRootViewController(presentedViewController!)
//
//        let searchViewController = presentedViewController!.viewControllers.first as! SearchViewController
//        searchViewController.viewModel.interfaceState.results?.first?.selectionHandler?()
//
//        wait(for: [dismissViewControllerExpectation], timeout: 10)
//    }
    
    func testAssertions() {
        
        let formPickerItem = FormPickerItem<FormPickerElement>(
            preselectedValue: nil,
            selectableValues: [],
            title: "",
            placeholder: "",
            style: .init(),
            presenter: nil
        )
        
        // Test resetValue()
        
        let resetValueException = expectation(description: "resetValue() should throw an exception")
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "'resetValue()' needs to be implemented on 'FormPickerItem<FormPickerElement>'")
            resetValueException.fulfill()
        }
        
        formPickerItem.resetValue()
        
        wait(for: [resetValueException], timeout: 10)
        
        // Test updateValidationFailureMessage()
        
        let updateValidationFailureMessageException = expectation(description: "updateValidationFailureMessage() should throw an exception")
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "'updateValidationFailureMessage()' needs to be implemented on 'FormPickerItem<FormPickerElement>'")
            updateValidationFailureMessageException.fulfill()
        }
        
        formPickerItem.updateValidationFailureMessage()
        
        wait(for: [updateValidationFailureMessageException], timeout: 10)
        
        // Test updateFormattedValue()
        
        let updateFormattedValueException = expectation(description: "updateFormattedValue() should throw an exception")
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "'updateFormattedValue()' needs to be implemented on 'FormPickerItem<FormPickerElement>'")
            updateFormattedValueException.fulfill()
        }
        
        formPickerItem.updateFormattedValue()
        
        wait(for: [updateFormattedValueException], timeout: 10)
        
        AdyenAssertion.listener = nil
    }

    func test_pickerItem_whenConfigurationOmitted_shouldDefaultToNoHeader() {
        let formPickerItem = FormPickerItem<FormPickerElement>(
            preselectedValue: nil,
            selectableValues: [],
            title: "",
            placeholder: "",
            style: .init(),
            presenter: nil
        )

        XCTAssertNil(formPickerItem.configuration.header)
    }

    func test_pickerItem_whenConfigurationHasHeader_shouldPresentPickerWithHeader() throws {
        let secondaryColor: UIColor = .purple
        let theme = CheckoutTheme(colors: CheckoutColors(textSecondary: secondaryColor))
        let presentationExpectation = expectation(description: "presenter.presentViewController was called")

        var presentedViewController: UIViewController?
        let presenter = PresenterMock(
            present: { viewController, _ in
                presentedViewController = viewController
                presentationExpectation.fulfill()
            },
            dismiss: { _ in }
        )

        let formPickerItem = FormPickerItem<FormPickerElement>(
            preselectedValue: nil,
            selectableValues: [.init(identifier: "Identifier", title: "Title", subtitle: "Subtitle")],
            title: "Installments",
            placeholder: "",
            style: .init(),
            presenter: presenter,
            configuration: .init(header: .init(title: "Installments", subtitle: "Split the total cost into monthly payments."))
        )

        // FormPickerItemView installs the selection handler that presents the picker.
        _ = FormPickerItemView(item: formPickerItem, theme: theme)

        formPickerItem.selectionHandler()

        wait(for: [presentationExpectation], timeout: 10)

        let pickerViewController = try XCTUnwrap(presentedViewController as? FormPickerSearchViewController<FormPickerElement>)
        setupRootViewController(pickerViewController)

        let searchViewController = try XCTUnwrap(pickerViewController.viewControllers.first as? SearchViewController)
        let headerView = try XCTUnwrap(searchViewController.headerView as? FormPickerHeaderView)
        XCTAssertEqual(headerView.titleLabel.text, "Installments")
        XCTAssertEqual(headerView.subtitleLabel.text, "Split the total cost into monthly payments.")
        XCTAssertEqual(headerView.subtitleLabel.textColor, secondaryColor)
        XCTAssertNil(searchViewController.title)
    }

    func test_pickerItem_whenConfigurationOmitted_shouldPresentPickerWithoutHeader() throws {
        let presentationExpectation = expectation(description: "presenter.presentViewController was called")

        var presentedViewController: UIViewController?
        let presenter = PresenterMock(
            present: { viewController, _ in
                presentedViewController = viewController
                presentationExpectation.fulfill()
            },
            dismiss: { _ in }
        )

        let formPickerItem = FormPickerItem<FormPickerElement>(
            preselectedValue: nil,
            selectableValues: [.init(identifier: "Identifier", title: "Title", subtitle: "Subtitle")],
            title: "Country/Region",
            placeholder: "",
            style: .init(),
            presenter: presenter
        )

        _ = FormPickerItemView(item: formPickerItem, theme: .default)

        formPickerItem.selectionHandler()

        wait(for: [presentationExpectation], timeout: 10)

        let pickerViewController = try XCTUnwrap(presentedViewController as? FormPickerSearchViewController<FormPickerElement>)
        setupRootViewController(pickerViewController)

        let searchViewController = try XCTUnwrap(pickerViewController.viewControllers.first as? SearchViewController)
        XCTAssertNil(searchViewController.headerView)
        XCTAssertEqual(searchViewController.title, "Country/Region")
    }
}
