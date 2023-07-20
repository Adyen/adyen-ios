//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

extension SearchViewController.InterfaceState {
    
    var results: [ListItem]? {
        switch self {
        case let .showingResults(results): return results
        case .loading: return nil
        case .empty: return nil
        }
    }
    
    var emptyStateSearchTerm: String? {
        switch self {
        case .showingResults: return nil
        case .loading: return nil
        case let .empty(searchTerm): return searchTerm
        }
    }
}

class FormPickerSearchViewControllerTests: XCTestCase {
    
    func testSetup() throws {
        
        let option: FormPickerElement = .init(identifier: "Identifier", title: "Title", subtitle: "Subtitle")
        
        let expectation = expectation(description: "Selection handler was executed")
        
        let pickerSearchViewController = FormPickerSearchViewController(
            title: nil,
            options: [option]
        ) { element in
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
    
    func testSearchSuccess() throws {
        
        // Given
        
        let option: FormPickerElement = .init(identifier: "Identifier", title: "Title", subtitle: "Subtitle")
        
        let pickerSearchViewController = FormPickerSearchViewController(
            title: nil,
            options: [option]
        ) { _ in }
        
        // Allow setup in viewDidLoad
        UIApplication.shared.keyWindow?.rootViewController = pickerSearchViewController
        wait(for: .milliseconds(300))
        
        let searchViewController = pickerSearchViewController.viewControllers.first as! SearchViewController
        
        let searchTerms: [String] = [
            "Title",
            "Subtitle",
            "Identifier"
        ]
        
        searchTerms.forEach {
            
            // When
            
            searchViewController.searchBar.delegate?.searchBar?(
                searchViewController.searchBar,
                textDidChange: $0
            )
            
            // Then
            
            XCTAssertEqual(searchViewController.viewModel.interfaceState.results?.first?.title, option.title)
            XCTAssertEqual(searchViewController.viewModel.interfaceState.results?.first?.subtitle, option.subtitle)
        }
    }
    
    func testSearchNoResults() throws {
        
        // Given
        
        let option: FormPickerElement = .init(identifier: "Identifier", title: "Title", subtitle: "Subtitle")
        
        let pickerSearchViewController = FormPickerSearchViewController(
            title: nil,
            options: [option]
        ) { _ in }
        
        // Allow setup in viewDidLoad
        UIApplication.shared.keyWindow?.rootViewController = pickerSearchViewController
        wait(for: .milliseconds(300))
        
        let searchViewController = pickerSearchViewController.viewControllers.first as! SearchViewController
        
        let searchTerms: [String] = [
            "Titles",
            "1",
            "Ola"
        ]
        
        searchTerms.forEach {
            
            // When
            
            searchViewController.searchBar.delegate?.searchBar?(
                searchViewController.searchBar,
                textDidChange: $0
            )
            
            // Then
            
            XCTAssertEqual(searchViewController.viewModel.interfaceState.emptyStateSearchTerm, $0)
        }
    }
}
