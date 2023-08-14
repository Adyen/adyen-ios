//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class FormPickerItemTests: XCTestCase {
    
    class MockPresenter: ViewControllerPresenter {
        
        var present: (UIViewController, Bool) -> Void
        var dismiss: (Bool) -> Void
        
        init(
            present: @escaping (UIViewController, Bool) -> Void,
            dismiss: @escaping (Bool) -> Void
        ) {
            self.present = present
            self.dismiss = dismiss
        }
        
        func presentViewController(_ viewController: UIViewController, animated: Bool) {
            present(viewController, animated)
        }
        
        func dismissViewController(animated: Bool) {
            dismiss(animated)
        }
    }
    
    func testPresentation() throws {
        
        let presentViewControllerExpectation = expectation(description: "presenter.presentViewController was called")
        let dismissViewControllerExpectation = expectation(description: "presenter.dismissViewController was called")
        
        var presentedViewController: FormPickerSearchViewController?
        
        let mockPresenter = MockPresenter { viewController, animated in
            presentedViewController = viewController as? FormPickerSearchViewController
            presentViewControllerExpectation.fulfill()
        } dismiss: { animated in
            dismissViewControllerExpectation.fulfill()
        }
        
        let formPickerItem = FormPickerItem(
            preselectedValue: nil,
            selectableValues: [.init(identifier: "Identifier", title: "Title", subtitle: "Subtitle")],
            title: "",
            placeholder: "",
            style: .init(),
            presenter: mockPresenter
        )
        
        // Setting up formPickerItem
        _ = FormPickerItemView(item: formPickerItem)
        
        formPickerItem.selectionHandler()
        
        wait(for: [presentViewControllerExpectation], timeout: 1)
        
        UIApplication.shared.keyWindow?.rootViewController? = presentedViewController!
        self.wait(for: .milliseconds(300))
        
        let searchViewController = presentedViewController!.viewControllers.first as! SearchViewController
        searchViewController.viewModel.interfaceState.results?.first?.selectionHandler?()
        
        wait(for: [dismissViewControllerExpectation], timeout: 1)
    }
    
    func testAssertions() throws {
        
        let formPickerItem = FormPickerItem(
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
            XCTAssertEqual(assertion, "'resetValue()' needs to be implemented on 'FormPickerItem'")
            resetValueException.fulfill()
        }
        
        formPickerItem.resetValue()
        
        wait(for: [resetValueException], timeout: 1)
        
        // Test updateValidationFailureMessage()
        
        let updateValidationFailureMessageException = expectation(description: "updateValidationFailureMessage() should throw an exception")
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "'updateValidationFailureMessage()' needs to be implemented on 'FormPickerItem'")
            updateValidationFailureMessageException.fulfill()
        }
        
        formPickerItem.updateValidationFailureMessage()
        
        wait(for: [updateValidationFailureMessageException], timeout: 1)
        
        // Test updateFormattedValue()
        
        let updateFormattedValueException = expectation(description: "updateFormattedValue() should throw an exception")
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "'updateFormattedValue()' needs to be implemented on 'FormPickerItem'")
            updateFormattedValueException.fulfill()
        }
        
        formPickerItem.updateFormattedValue()
        
        wait(for: [updateFormattedValueException], timeout: 1)
        
        AdyenAssertion.listener = nil
    }
}
