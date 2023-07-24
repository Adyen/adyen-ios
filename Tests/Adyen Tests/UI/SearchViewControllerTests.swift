//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class SearchViewControllerTests: XCTestCase {
    
    class DummyEmptyView: UIView, SearchResultsEmptyView {
        
        var searchTerm: String = ""
        
        init() {
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    struct DummyStyle: ViewStyle {
        var backgroundColor: UIColor = .clear
    }
    
    var sut: LoadingView!
    var viewController: SearchViewController!
    var emptyView: DummyEmptyView!
    
    override func setUp() {
        super.setUp()
        
        emptyView = DummyEmptyView()
    }
    
    // MARK: - ViewModel
    
    func testViewModelHandleViewDidLoad() {
        
        let handleViewDidLoadExpectation = expectation(description: "Result provider was called on handleViewDidLoad")
        
        let viewModel = SearchViewController.ViewModel(
            style: DummyStyle()
        ) { searchTerm, handler in
            DispatchQueue.main.async {
                handleViewDidLoadExpectation.fulfill()
                handler([])
            }
        }
        
        // handleViewDidLoad
        viewModel.handleViewDidLoad()
        wait(for: [handleViewDidLoadExpectation], timeout: 2)
        XCTAssertEqual(viewModel.interfaceState, .empty(searchTerm: ""))
    }
    
    func testViewModelStateCycling() {
        
        let resultsSearchTerm = "Results"
        let emptySearchTerm = "Empty"
        let resultItems = [ListItem(title: "Result")]
        
        let viewModel = SearchViewController.ViewModel(
            style: DummyStyle()
        ) { searchTerm, handler in
            DispatchQueue.main.async {
                if searchTerm == resultsSearchTerm {
                    handler(resultItems)
                } else {
                    handler([])
                }
            }
        }
        
        // Empty -> Loading -> Results
        XCTAssertEqual(viewModel.interfaceState, .empty(searchTerm: ""))
        viewModel.handleSearchTextDidChange(resultsSearchTerm)
        XCTAssertEqual(viewModel.interfaceState, .loading)
        wait(for: .milliseconds(50))
        XCTAssertEqual(viewModel.interfaceState, .showingResults(results: resultItems))
        
        // Results -> Loading -> Results
        viewModel.handleSearchTextDidChange(resultsSearchTerm)
        XCTAssertEqual(viewModel.interfaceState, .loading)
        wait(for: .milliseconds(50))
        XCTAssertEqual(viewModel.interfaceState, .showingResults(results: resultItems))
        
        // Results -> Loading -> Empty
        viewModel.handleSearchTextDidChange(emptySearchTerm)
        XCTAssertEqual(viewModel.interfaceState, .loading)
        wait(for: .milliseconds(50))
        XCTAssertEqual(viewModel.interfaceState, .empty(searchTerm: emptySearchTerm))
        
        // Empty -> Loading -> Empty
        viewModel.handleSearchTextDidChange(emptySearchTerm)
        XCTAssertEqual(viewModel.interfaceState, .loading)
        wait(for: .milliseconds(50))
        XCTAssertEqual(viewModel.interfaceState, .empty(searchTerm: emptySearchTerm))
    }
    
    // MARK: - SearchViewController
    
    func testViewModelBinding() {
        
        let testSearchTerm = "This is a search"
        
        let expectation = expectation(description: "Result provider was called")
        var expectedLookups = ["", testSearchTerm]
        
        let viewModel = SearchViewController.ViewModel(
            style: DummyStyle()
        ) { searchTerm, handler in
            DispatchQueue.main.async {
                XCTAssertEqual(searchTerm, expectedLookups.first!)
                expectedLookups = Array(expectedLookups.dropFirst())
                
                handler([])
                
                if searchTerm == testSearchTerm {
                    expectation.fulfill()
                }
            }
        }
        
        let searchViewController = SearchViewController(
            viewModel: viewModel,
            emptyView: emptyView
        )
        
        // Allow setup in viewDidLoad
        UIApplication.shared.keyWindow?.rootViewController = searchViewController
        wait(for: .milliseconds(50))
        
        searchViewController.searchBar.delegate?.searchBar?(
            searchViewController.searchBar,
            textDidChange: testSearchTerm
        )
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(viewModel.interfaceState, .empty(searchTerm: testSearchTerm))
        XCTAssertTrue(expectedLookups.isEmpty)
    }
    
    func testInterfaceStateEmpty() throws {
        
        // Given
        let testSearchTerm = "This is a search"
        
        let viewModel = SearchViewController.ViewModel(
            style: DummyStyle()
        ) { searchTerm, handler in
            handler([])
        }
        
        let searchViewController = SearchViewController(
            viewModel: viewModel,
            emptyView: emptyView
        )
        
        UIApplication.shared.keyWindow?.rootViewController = searchViewController
        wait(for: .milliseconds(50))
        
        // When
        viewModel.interfaceState = .empty(searchTerm: testSearchTerm)
        
        // Then
        XCTAssertTrue(searchViewController.loadingView.isHidden)
        XCTAssertTrue(searchViewController.resultsListViewController.view.isHidden)
        XCTAssertFalse(searchViewController.emptyView.isHidden)
        XCTAssertEqual(searchViewController.emptyView.searchTerm, testSearchTerm)
    }
    
    func testInterfaceStateLoading() throws {
        
        // Given
        let viewModel = SearchViewController.ViewModel(
            style: DummyStyle()
        ) { searchTerm, handler in
            handler([])
        }
        
        let searchViewController = SearchViewController(
            viewModel: viewModel,
            emptyView: emptyView
        )
        
        UIApplication.shared.keyWindow?.rootViewController = searchViewController
        wait(for: .milliseconds(50))
        
        // When
        viewModel.interfaceState = .loading
        
        // Then
        XCTAssertFalse(searchViewController.loadingView.isHidden)
        XCTAssertTrue(searchViewController.resultsListViewController.view.isHidden)
        XCTAssertTrue(searchViewController.emptyView.isHidden)
    }
    
    func testInterfaceStateShowingResults() throws {
        
        // Given
        let resultItems = [ListItem(title: "Result")]
        
        let viewModel = SearchViewController.ViewModel(
            style: DummyStyle()
        ) { searchTerm, handler in
            handler([])
        }
        
        let searchViewController = SearchViewController(
            viewModel: viewModel,
            emptyView: emptyView
        )
        
        UIApplication.shared.keyWindow?.rootViewController = searchViewController
        wait(for: .milliseconds(50))
        
        // When
        viewModel.interfaceState = .showingResults(results: resultItems)
        
        // Then
        XCTAssertTrue(searchViewController.loadingView.isHidden)
        XCTAssertFalse(searchViewController.resultsListViewController.view.isHidden)
        XCTAssertEqual(searchViewController.resultsListViewController.sections.first!.items, resultItems)
        XCTAssertTrue(searchViewController.emptyView.isHidden)
    }
}
