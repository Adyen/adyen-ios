//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
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
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func test_picker_whenOptionSelected_shouldInvokeSelectionHandlerWithSelectedOption() throws {
        
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
        setupRootViewController(pickerSearchViewController)
        
        let searchViewController = try XCTUnwrap(pickerSearchViewController.viewControllers.first as? SearchViewController)
        guard case let .showingResults(results) = searchViewController.viewModel.interfaceState else {
            XCTFail("SearchViewController has wrong state \(searchViewController.viewModel.interfaceState)")
            return
        }
        
        results.first?.selectionHandler?()
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_search_withMatchingTerm_shouldReturnMatchingResults() throws {
        
        // Given
        
        let option: FormPickerElement = .init(identifier: "Identifier", title: "Title", subtitle: "Subtitle")
        
        let pickerSearchViewController = FormPickerSearchViewController(
            title: nil,
            options: [option]
        ) { _ in }
        
        // Allow setup in viewDidLoad
        pickerSearchViewController.loadViewIfNeeded()
        
        let searchViewController = try XCTUnwrap(pickerSearchViewController.viewControllers.first as? SearchViewController)
        
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
    
    func test_search_withNonMatchingTerm_shouldShowEmptyState() throws {
        
        // Given
        
        let option: FormPickerElement = .init(identifier: "Identifier", title: "Title", subtitle: "Subtitle")
        
        let pickerSearchViewController = FormPickerSearchViewController(
            title: nil,
            options: [option]
        ) { _ in }
        
        // Allow setup in viewDidLoad
        pickerSearchViewController.loadViewIfNeeded()
        
        let searchViewController = try XCTUnwrap(pickerSearchViewController.viewControllers.first as? SearchViewController)
        
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

    func test_pickerHeader_whenSubtitleProvided_shouldRenderTitleAndSubtitle() throws {
        let searchViewController = try makeSearchViewController(
            configuration: .init(header: .init(title: "Installments", subtitle: "Split the total cost into monthly payments."))
        )

        let headerView = try XCTUnwrap(searchViewController.headerView as? FormPickerHeaderView)
        XCTAssertEqual(headerView.titleLabel.text, "Installments")
        XCTAssertEqual(headerView.subtitleLabel.text, "Split the total cost into monthly payments.")
        XCTAssertFalse(headerView.subtitleLabel.isHidden)
        XCTAssertTrue(headerView.isDescendant(of: searchViewController.view))
        // Title lives in the header, so it is not duplicated in the navigation bar.
        XCTAssertNil(searchViewController.title)
    }

    func test_pickerHeader_whenHeaderAbsent_shouldUseNavigationTitle() throws {
        let searchViewController = try makeSearchViewController(title: "Country/Region")

        XCTAssertNil(searchViewController.headerView)
        XCTAssertEqual(searchViewController.title, "Country/Region")
    }

    func test_pickerHeader_whenTitleAndSubtitleEmpty_shouldUseNavigationTitle() throws {
        let searchViewController = try makeSearchViewController(
            title: "Installments",
            configuration: .init(header: .init(title: "", subtitle: ""))
        )

        XCTAssertNil(searchViewController.headerView)
        XCTAssertEqual(searchViewController.title, "Installments")
    }

    func test_pickerHeader_whenTitleEmptyAndSubtitleProvided_shouldUseNavigationTitle() throws {
        let searchViewController = try makeSearchViewController(
            title: "Installments",
            configuration: .init(
                header: .init(
                    title: "",
                    subtitle: "Split the total cost into monthly payments."
                )
            )
        )

        XCTAssertNil(searchViewController.headerView)
        XCTAssertEqual(searchViewController.title, "Installments")
    }

    func test_pickerHeader_whenSubtitleEmpty_shouldHideSubtitleLabel() throws {
        let searchViewController = try makeSearchViewController(
            configuration: .init(header: .init(title: "Installments", subtitle: ""))
        )

        let headerView = try XCTUnwrap(searchViewController.headerView as? FormPickerHeaderView)
        XCTAssertEqual(headerView.titleLabel.text, "Installments")
        XCTAssertTrue(headerView.subtitleLabel.isHidden)
    }

    func test_pickerHeader_shouldApplySecondaryColorToSubtitle() throws {
        let secondaryColor: UIColor = .purple

        let searchViewController = try makeSearchViewController(
            configuration: .init(header: .init(title: "Installments", subtitle: "Split the total cost into monthly payments.")),
            theme: CheckoutTheme(colors: CheckoutColors(textSecondary: secondaryColor))
        )

        let headerView = try XCTUnwrap(searchViewController.headerView as? FormPickerHeaderView)
        XCTAssertEqual(headerView.subtitleLabel.textColor, secondaryColor)
    }

    func test_pickerHeader_whenSubtitleNil_shouldHideSubtitleLabel() throws {
        let searchViewController = try makeSearchViewController(
            configuration: .init(header: .init(title: "Installments"))
        )

        let headerView = try XCTUnwrap(searchViewController.headerView as? FormPickerHeaderView)
        XCTAssertEqual(headerView.titleLabel.text, "Installments")
        XCTAssertNil(headerView.subtitleLabel.text)
        XCTAssertTrue(headerView.subtitleLabel.isHidden)
    }

    // MARK: - Helpers

    private func makeSearchViewController(
        title: String? = nil,
        configuration: FormPickerConfiguration = .init(),
        theme: CheckoutTheme = .default,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> SearchViewController {
        let option = FormPickerElement(identifier: "Identifier", title: "Title", subtitle: "Subtitle")

        let pickerSearchViewController = FormPickerSearchViewController(
            title: title,
            configuration: configuration,
            theme: theme,
            options: [option]
        ) { _ in }

        // Allow setup in viewDidLoad
        setupRootViewController(pickerSearchViewController)

        return try XCTUnwrap(
            pickerSearchViewController.viewControllers.first as? SearchViewController,
            file: file,
            line: line
        )
    }
}
