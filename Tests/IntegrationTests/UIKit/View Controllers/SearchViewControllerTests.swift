//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class SearchViewControllerTests: XCTestCase {
    
    class DummyEmptyView: UIView, SearchResultsEmptyView {
        
        var searchTerm: String = ""
        
        init() {
            super.init(frame: .zero)
        }
        
        @available(*, unavailable)
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
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    override func setUp() {
        super.setUp()
        
        emptyView = DummyEmptyView()
    }
    
    // MARK: - ViewModel
    
    func test_viewModel_whenLoaded_shouldRequestInitialResults() {
        
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
        wait(for: [handleViewDidLoadExpectation], timeout: 10)
        XCTAssertEqual(viewModel.interfaceState, .empty(searchTerm: ""))
    }
    
    func test_viewModel_whenResultsChange_shouldUpdateInterfaceState() {
        
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
        wait(for: .milliseconds(300))
        XCTAssertEqual(viewModel.interfaceState, .showingResults(results: resultItems))
        
        // Results -> Loading -> Results
        viewModel.handleSearchTextDidChange(resultsSearchTerm)
        XCTAssertEqual(viewModel.interfaceState, .loading)
        wait(for: .milliseconds(300))
        XCTAssertEqual(viewModel.interfaceState, .showingResults(results: resultItems))
        
        // Results -> Loading -> Empty
        viewModel.handleSearchTextDidChange(emptySearchTerm)
        XCTAssertEqual(viewModel.interfaceState, .loading)
        wait(for: .milliseconds(300))
        XCTAssertEqual(viewModel.interfaceState, .empty(searchTerm: emptySearchTerm))
        
        // Empty -> Loading -> Empty
        viewModel.handleSearchTextDidChange(emptySearchTerm)
        XCTAssertEqual(viewModel.interfaceState, .loading)
        wait(for: .milliseconds(300))
        XCTAssertEqual(viewModel.interfaceState, .empty(searchTerm: emptySearchTerm))
    }
    
    // MARK: - SearchViewController
    
    func test_searchBar_whenTextChanges_shouldRequestMatchingResults() {
        
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
        searchViewController.loadViewIfNeeded()
        
        searchViewController.searchBar.delegate?.searchBar?(
            searchViewController.searchBar,
            textDidChange: testSearchTerm
        )
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(viewModel.interfaceState, .empty(searchTerm: testSearchTerm))
        XCTAssertTrue(expectedLookups.isEmpty)
    }
    
    func test_searchBar_whenVisibilityOmitted_shouldBeAddedToViewHierarchy() {
        let searchViewController = makeSearchViewController()

        searchViewController.loadViewIfNeeded()

        XCTAssertTrue(searchViewController.searchBar.isDescendant(of: searchViewController.view))
    }

    func test_searchBar_whenHiddenAndFocusRequested_shouldNotBeAddedOrFocused() {
        let searchViewController = makeSearchViewController(
            shouldShowSearchBar: false,
            shouldFocusSearchBarOnAppearance: true
        )

        setupRootViewController(searchViewController)

        XCTAssertFalse(searchViewController.searchBar.isDescendant(of: searchViewController.view))
        XCTAssertFalse(searchViewController.searchBar.isFirstResponder)
    }

    func test_content_whenSearchBarHiddenAndHeaderAbsent_shouldStartAtTopMargin() {
        let searchViewController = makeSearchViewController(shouldShowSearchBar: false)

        setupRootViewController(searchViewController)
        searchViewController.view.layoutIfNeeded()

        let expectedMinY = searchViewController.view.layoutMarginsGuide.layoutFrame.minY

        XCTAssertEqual(
            searchViewController.resultsListViewController.view.frame.minY,
            expectedMinY,
            accuracy: 0.1
        )
        XCTAssertEqual(searchViewController.emptyView.frame.minY, expectedMinY, accuracy: 0.1)
        XCTAssertEqual(searchViewController.loadingView.frame.minY, expectedMinY, accuracy: 0.1)
    }

    func test_content_whenSearchBarHiddenAndHeaderPresent_shouldStartBelowHeader() {
        let headerView = UIView()
        headerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let searchViewController = makeSearchViewController(
            headerView: headerView,
            shouldShowSearchBar: false
        )

        setupRootViewController(searchViewController)
        searchViewController.view.layoutIfNeeded()

        let expectedMinY = headerView.frame.maxY + 8

        XCTAssertEqual(
            searchViewController.resultsListViewController.view.frame.minY,
            expectedMinY,
            accuracy: 0.1
        )
        XCTAssertEqual(searchViewController.emptyView.frame.minY, expectedMinY, accuracy: 0.1)
        XCTAssertEqual(searchViewController.loadingView.frame.minY, expectedMinY, accuracy: 0.1)
    }

    func test_interfaceState_whenEmpty_shouldShowEmptyView() {
        
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
        
        searchViewController.loadViewIfNeeded()
        
        // When
        viewModel.interfaceState = .empty(searchTerm: testSearchTerm)
        
        // Then
        XCTAssertTrue(searchViewController.loadingView.isHidden)
        XCTAssertTrue(searchViewController.resultsListViewController.view.isHidden)
        XCTAssertFalse(searchViewController.emptyView.isHidden)
        XCTAssertEqual(searchViewController.emptyView.searchTerm, testSearchTerm)
    }
    
    func test_interfaceState_whenLoading_shouldShowLoadingView() {
        
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
        
        searchViewController.loadViewIfNeeded()
        
        // When
        viewModel.interfaceState = .loading
        
        // Then
        XCTAssertFalse(searchViewController.loadingView.isHidden)
        XCTAssertTrue(searchViewController.resultsListViewController.view.isHidden)
        XCTAssertTrue(searchViewController.emptyView.isHidden)
    }
    
    func test_interfaceState_whenShowingResults_shouldShowResultsList() {
        
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
        
        searchViewController.loadViewIfNeeded()
        
        // When
        viewModel.interfaceState = .showingResults(results: resultItems)
        
        // Then
        XCTAssertTrue(searchViewController.loadingView.isHidden)
        XCTAssertFalse(searchViewController.resultsListViewController.view.isHidden)
        XCTAssertEqual(searchViewController.resultsListViewController.sections.first?.items, resultItems)
        XCTAssertTrue(searchViewController.emptyView.isHidden)
    }
    
    func test_emptyView_whenKeyboardFrameChanges_shouldUpdateBottomConstraint() throws {
        let viewModel = SearchViewController.ViewModel(
            style: DummyStyle()
        ) { _, handler in
            handler([])
        }
        
        let searchViewController = SearchViewController(
            viewModel: viewModel,
            emptyView: emptyView
        )
        
        searchViewController.loadViewIfNeeded()
        
        let bottomConstraint = try emptyViewBottomConstraint(from: searchViewController)
        postKeyboardFrameChange(to: makeKeyboardFrame(withHeight: 100))
        
        wait(
            until: { abs(bottomConstraint.constant + 100) < 0.1 },
            timeout: 1.0,
            file: #file,
            line: #line
        )
        
        XCTAssertEqual(bottomConstraint.constant, -100, accuracy: 0.1)
    }
}

private extension SearchViewControllerTests {
    
    func makeSearchViewController(
        headerView: UIView? = nil,
        shouldShowSearchBar: Bool = true,
        shouldFocusSearchBarOnAppearance: Bool = false
    ) -> SearchViewController {
        let viewModel = SearchViewController.ViewModel(
            localizationParameters: nil,
            style: DummyStyle(),
            searchBarPlaceholder: nil,
            shouldShowSearchBar: shouldShowSearchBar,
            shouldFocusSearchBarOnAppearance: shouldFocusSearchBarOnAppearance
        ) { _, handler in
            handler([ListItem(title: "Result")])
        }

        return SearchViewController(
            viewModel: viewModel,
            emptyView: emptyView,
            headerView: headerView
        )
    }

    func emptyViewBottomConstraint(
        from searchViewController: SearchViewController,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> NSLayoutConstraint {
        try XCTUnwrap(
            searchViewController.view.constraints.first(where: {
                ($0.firstItem as AnyObject?) === searchViewController.emptyView
                    && $0.firstAttribute == .bottom
                    && ($0.secondItem as AnyObject?) === searchViewController.view
                    && $0.secondAttribute == .bottom
            }),
            file: file,
            line: line
        )
    }
    
    func makeKeyboardFrame(withHeight height: CGFloat) -> CGRect {
        CGRect(
            x: UIScreen.main.bounds.minX,
            y: UIScreen.main.bounds.maxY - height,
            width: UIScreen.main.bounds.width,
            height: height
        )
    }
    
    func postKeyboardFrameChange(to frame: CGRect) {
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardFrameEndUserInfoKey: frame,
                UIResponder.keyboardAnimationDurationUserInfoKey: 0.25,
                UIResponder.keyboardAnimationCurveUserInfoKey: UIView.AnimationCurve.easeInOut.rawValue
            ]
        )
    }
}
