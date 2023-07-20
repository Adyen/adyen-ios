//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class FormPickerSearchViewControllerTests: XCTestCase {
    
    func testSetup() throws {
        
        let option: FormPickerElement = .init(identifier: "Identifier", title: "Title", subtitle: "Subtitle")
        
        let expectation = expectation(description: "Selection handler was executed")
        
        let pickerSearchViewController = FormPickerSearchViewController(
            title: nil,
            options: [option]) { element in
                XCTAssertEqual(element.identifier, option.identifier)
                XCTAssertEqual(element.icon, option.icon)
                XCTAssertEqual(element.title, option.title)
                XCTAssertEqual(element.subtitle, option.subtitle)
                
                expectation.fulfill()
            }
        
        // Allow setup in viewDidLoad
        UIApplication.shared.keyWindow?.rootViewController = pickerSearchViewController
        wait(for: .milliseconds(300))
        
        let searchViewController = pickerSearchViewController.viewControllers.first as! SearchViewController
        guard case let .showingResults(results) = searchViewController.viewModel.interfaceState else {
            XCTFail("SearchViewController has wrong state \(searchViewController.viewModel.interfaceState)")
            return
        }
        
        results.first?.selectionHandler?()
        
        wait(for: [expectation], timeout: 1)
    }
}
