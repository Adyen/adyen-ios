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
    
    /// When a shopper opens a picker and chooses an option, the field must update and the presenter must close that same picker.
    /// The picker is content-only, so it delegates dismissal rather than assuming it is presented modally or pushed.
    func test_pickerItem_whenOptionSelected_shouldUpdateValueAndDismissPresentedPicker() throws {
        final class PresenterSpy: ViewControllerPresenter {
            var presentations: [(viewController: UIViewController, animated: Bool)] = []
            var dismissals: [(viewController: UIViewController, animated: Bool)] = []

            func presentViewController(_ viewController: UIViewController, animated: Bool) {
                presentations.append((viewController, animated))
            }

            func dismissViewController(_ viewController: UIViewController, animated: Bool) {
                dismissals.append((viewController, animated))
            }
        }

        let presenter = PresenterSpy()
        let option = FormPickerElement(identifier: "Identifier", title: "Title", subtitle: "Subtitle")
        let item = FormPickerItem<FormPickerElement>(
            preselectedValue: nil,
            selectableValues: [option],
            placeholder: "",
            style: .init(),
            presenter: presenter,
            configuration: .init(title: "Choose an option")
        )
        let itemView = FormPickerItemView(item: item, theme: .default)

        // Keep the view alive because the selection handler captures it weakly; a view hierarchy normally retains it.
        try withExtendedLifetime(itemView) {
            // Opening the field requests one animated presentation of the content-only picker.
            item.selectionHandler()

            XCTAssertEqual(presenter.presentations.count, 1)
            let presentation = try XCTUnwrap(presenter.presentations.first)
            XCTAssertTrue(presentation.animated)
            let picker = try XCTUnwrap(presentation.viewController as? FormPickerSearchViewController<FormPickerElement>)
            picker.loadViewIfNeeded()
            // Opening the picker alone must not request dismissal.
            XCTAssertTrue(presenter.dismissals.isEmpty)
            let result = try XCTUnwrap(picker.viewModel.interfaceState.results?.first)
            let select = try XCTUnwrap(result.selectionHandler)

            // Simulate the shopper choosing the available option.
            select()

            // Selection updates the field and requests animated dismissal of the exact picker that was presented.
            XCTAssertEqual(item.value?.identifier, option.identifier)
            XCTAssertEqual(presenter.dismissals.count, 1)
            let dismissal = try XCTUnwrap(presenter.dismissals.first)
            XCTAssertTrue(dismissal.viewController === picker)
        }
    }
    
    func test_abstractMethods_whenNotOverridden_shouldTriggerAssertions() {
        
        let formPickerItem = FormPickerItem<FormPickerElement>(
            preselectedValue: nil,
            selectableValues: [],
            placeholder: "",
            style: .init(),
            presenter: nil,
            configuration: .init(title: "")
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

    func test_pickerItem_withConfiguredTitle_shouldUseConfigurationTitle() {
        let expectedTitle = "Choose a payment plan"
        let formPickerItem = FormPickerItem<FormPickerElement>(
            preselectedValue: nil,
            selectableValues: [],
            placeholder: "",
            style: .init(),
            presenter: nil,
            configuration: .init(title: expectedTitle)
        )

        XCTAssertEqual(formPickerItem.title, expectedTitle)
        XCTAssertEqual(formPickerItem.configuration.title, expectedTitle)
        XCTAssertNil(formPickerItem.configuration.subtitle)
        XCTAssertTrue(formPickerItem.configuration.isSearchEnabled)
    }

    func test_pickerItem_whenHeaderConfiguredAndSearchDisabled_shouldPresentPickerWithHeaderAndNoSearchBar() throws {
        let secondaryColor: UIColor = .orange
        let theme = CheckoutTheme(
            colors: CheckoutColors(
                primary: .purple,
                textSecondary: secondaryColor
            )
        )
        let presentationExpectation = expectation(description: "presenter.presentViewController was called")

        var presentedViewController: UIViewController?
        let presenter = PresenterMock(
            present: { viewController, _ in
                presentedViewController = viewController
                presentationExpectation.fulfill()
            },
            dismiss: { _ in }
        )

        let selectedOption = FormPickerElement(
            identifier: "Identifier",
            title: "Title",
            subtitle: "Subtitle"
        )
        let formPickerItem = FormPickerItem<FormPickerElement>(
            preselectedValue: selectedOption,
            selectableValues: [selectedOption],
            placeholder: "",
            style: .init(),
            presenter: presenter,
            configuration: .init(
                title: "Installments",
                subtitle: "Split the total cost into monthly payments.",
                isSearchEnabled: false
            )
        )

        // FormPickerItemView installs the selection handler that presents the picker.
        _ = FormPickerItemView(item: formPickerItem, theme: theme)

        formPickerItem.selectionHandler()

        wait(for: [presentationExpectation], timeout: 10)

        let pickerViewController = try XCTUnwrap(presentedViewController as? FormPickerSearchViewController<FormPickerElement>)
        setupRootViewController(pickerViewController)

        let searchViewController: SearchViewController = pickerViewController
        let headerView = try XCTUnwrap(searchViewController.headerView as? FormPickerHeaderView)
        XCTAssertEqual(headerView.titleLabel.text, "Installments")
        XCTAssertEqual(headerView.subtitleLabel.text, "Split the total cost into monthly payments.")
        XCTAssertEqual(headerView.subtitleLabel.textColor, secondaryColor)
        XCTAssertNil(searchViewController.title)
        XCTAssertFalse(searchViewController.searchBar.isDescendant(of: searchViewController.view))
        XCTAssertEqual(
            searchViewController.viewModel.interfaceState.results?
                .filter(\.isSelected)
                .map(\.identifier),
            [selectedOption.identifier]
        )
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
            placeholder: "",
            style: .init(),
            presenter: presenter,
            configuration: .init(title: "Country/Region")
        )

        _ = FormPickerItemView(item: formPickerItem, theme: .default)

        formPickerItem.selectionHandler()

        wait(for: [presentationExpectation], timeout: 10)

        let pickerViewController = try XCTUnwrap(presentedViewController as? FormPickerSearchViewController<FormPickerElement>)
        setupRootViewController(pickerViewController)

        let searchViewController: SearchViewController = pickerViewController
        XCTAssertNil(searchViewController.headerView)
        XCTAssertEqual(searchViewController.title, "Country/Region")
        XCTAssertTrue(searchViewController.searchBar.isDescendant(of: searchViewController.view))
        XCTAssertFalse(
            try XCTUnwrap(searchViewController.viewModel.interfaceState.results)
                .contains(where: \.isSelected)
        )
    }
}
