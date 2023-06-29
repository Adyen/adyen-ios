//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class SearchViewControllerTests: XCTestCase {
    
    class DummyEmptyView: UIView, SearchViewControllerEmptyView {
        
        var searchTerm: String = ""
        
        init() {
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var sut: LoadingView!
    var viewController: SearchViewController!
    var emptyView: DummyEmptyView!
    
    override func setUp() {
        super.setUp()
        
        emptyView = DummyEmptyView()
    }

    func testEmptyViewSearchTermUpdate() throws {
        
        let testSearchTerm = "This is a search"
        
        let searchViewController = SearchViewController(
            style: TextStyle(font: .boldSystemFont(ofSize: 1), color: .red),
            emptyView: emptyView
        ) { searchTerm, handler in
            XCTAssertEqual(searchTerm, testSearchTerm)
            handler([])
        }
        
        searchViewController.searchBar.text = testSearchTerm
        searchViewController.searchBar.delegate?.searchBar?(
            searchViewController.searchBar,
            textDidChange: testSearchTerm
        )
        
        XCTAssertEqual(emptyView.searchTerm, testSearchTerm)
        XCTAssertFalse(searchViewController.emptyView.isHidden)
        XCTAssertTrue(searchViewController.resultsListViewController.view.isHidden)
        XCTAssertTrue(searchViewController.loadingView.isHidden)
    }
    
    func testStates() throws {
        
        let testSearchTerm = "This is a search"
        let resultItems = [ListItem(title: "Result")]
        let expectation = expectation(description: "Result provider was called")
        
        let searchViewController = SearchViewController(
            style: TextStyle(font: .boldSystemFont(ofSize: 1), color: .red),
            emptyView: emptyView
        ) { searchTerm, handler in
            if searchTerm == testSearchTerm {
                DispatchQueue.main.async {
                    handler(resultItems)
                    expectation.fulfill()
                }
                
                return
            }
            
            handler([])
        }
        
        UIApplication.shared.keyWindow?.rootViewController = searchViewController
        
        wait(for: .milliseconds(300))
        
        var interfaceStates = [SearchViewController.InterfaceState]()
        
        interfaceStates.append(searchViewController.interfaceState) // Empty ("")
        
        searchViewController.searchBar.delegate?.searchBar?(
            searchViewController.searchBar,
            textDidChange: ""
        )
        
        interfaceStates.append(searchViewController.interfaceState) // Loading
        
        wait(for: [expectation], timeout: 1)
        
        interfaceStates.append(searchViewController.interfaceState) // Showing Results (resultItems)
        
        XCTAssertEqual(interfaceStates, [.empty(searchTerm: ""), .loading, .showingResults(results: resultItems)])
    }
}
