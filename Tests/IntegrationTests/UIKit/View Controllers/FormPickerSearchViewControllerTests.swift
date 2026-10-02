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
            configuration: .init(isSearchEnabled: false),
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

    func test_picker_whenSelectedOptionProvided_shouldMarkMatchingResultAsSelected() throws {
        let options = makeOptions()
        let selectedBackgroundColor: UIColor = .purple
        let selectedOption = FormPickerElement(
            identifier: options[1].identifier,
            title: "Different title"
        )

        let searchViewController = try makeSearchViewController(
            theme: CheckoutTheme(
                colors: CheckoutColors(container: selectedBackgroundColor)
            ),
            options: options,
            selectedOption: selectedOption
        )

        let results = try XCTUnwrap(searchViewController.viewModel.interfaceState.results)
        let selectedResults = results.filter(\.isSelected)

        XCTAssertEqual(selectedResults.map(\.identifier), [selectedOption.identifier])
        XCTAssertEqual(selectedResults.first?.title, options[1].title)
        XCTAssertEqual(selectedResults.first?.style.backgroundColor, selectedBackgroundColor)
    }

    func test_picker_whenSelectedOptionProvided_shouldRenderSelectedCellAppearance() throws {
        let options = makeOptions()
        let selectedOption = options[1]
        let selectedBackgroundColor: UIColor = .purple
        let searchViewController = try makeSearchViewController(
            theme: CheckoutTheme(
                colors: CheckoutColors(container: selectedBackgroundColor)
            ),
            options: options,
            selectedOption: selectedOption
        )

        let resultsListViewController = searchViewController.resultsListViewController
        wait(until: { resultsListViewController.viewIfLoaded?.window != nil })

        let selectedCell = try XCTUnwrap(
            resultsListViewController.tableView.visibleCells
                .compactMap { $0 as? ListCell }
                .first { $0.item?.identifier == selectedOption.identifier }
        )
        let checkmarkImageView: UIImageView = try XCTUnwrap(
            selectedCell.findView(by: "checkmark")
        )

        XCTAssertEqual(selectedCell.backgroundColor, selectedBackgroundColor)
        XCTAssertEqual(selectedCell.layer.cornerRadius, AdyenUIConstants.defaultCornerRadius)
        XCTAssertFalse(checkmarkImageView.isHidden)
        XCTAssertTrue(selectedCell.accessibilityTraits.contains(.selected))
    }

    func test_picker_whenSelectedOptionOmitted_shouldNotMarkAnyResultAsSelected() throws {
        let searchViewController = try makeSearchViewController(
            options: makeOptions(),
            selectedOption: nil
        )

        let results = try XCTUnwrap(searchViewController.viewModel.interfaceState.results)

        XCTAssertFalse(results.contains(where: \.isSelected))
    }

    func test_picker_whenSelectedOptionIsNotAvailable_shouldNotMarkAnyResultAsSelected() throws {
        let searchViewController = try makeSearchViewController(
            options: makeOptions(),
            selectedOption: .init(identifier: "missing", title: "Missing")
        )

        let results = try XCTUnwrap(searchViewController.viewModel.interfaceState.results)

        XCTAssertFalse(results.contains(where: \.isSelected))
    }

    func test_search_whenSelectedOptionFilteredOutAndRestored_shouldUpdateVisibleSelection() throws {
        let options = makeOptions()
        let selectedOption = options[1]
        let searchViewController = try makeSearchViewController(
            options: options,
            selectedOption: selectedOption
        )

        XCTAssertEqual(
            searchViewController.viewModel.interfaceState.results?.filter(\.isSelected).map(\.identifier),
            [selectedOption.identifier]
        )

        searchViewController.searchBar.delegate?.searchBar?(
            searchViewController.searchBar,
            textDidChange: options[0].title
        )

        XCTAssertFalse(
            try XCTUnwrap(searchViewController.viewModel.interfaceState.results)
                .contains(where: \.isSelected)
        )

        searchViewController.searchBar.delegate?.searchBar?(
            searchViewController.searchBar,
            textDidChange: selectedOption.title
        )

        XCTAssertEqual(
            searchViewController.viewModel.interfaceState.results?.filter(\.isSelected).map(\.identifier),
            [selectedOption.identifier]
        )

        searchViewController.searchBar.delegate?.searchBar?(
            searchViewController.searchBar,
            textDidChange: ""
        )

        XCTAssertEqual(
            searchViewController.viewModel.interfaceState.results?.filter(\.isSelected).map(\.identifier),
            [selectedOption.identifier]
        )
    }

    func test_searchBar_whenConfigurationOmitted_shouldShowAndFocus() throws {
        let searchViewController = try makeSearchViewController()

        XCTAssertTrue(searchViewController.searchBar.isDescendant(of: searchViewController.view))
        wait(
            until: { searchViewController.searchBar.isFirstResponder },
            timeout: 1
        )
    }

    func test_picker_whenSearchDisabledAndHeaderAbsent_shouldShowResultsWithoutSearchBar() throws {
        let title = "Installments"
        let searchViewController = try makeSearchViewController(
            title: title,
            configuration: .init(isSearchEnabled: false)
        )

        XCTAssertFalse(searchViewController.searchBar.isDescendant(of: searchViewController.view))
        XCTAssertFalse(searchViewController.searchBar.isFirstResponder)
        XCTAssertEqual(searchViewController.title, title)
        XCTAssertEqual(searchViewController.resultsListViewController.sections.first?.items.count, 1)
    }

    func test_picker_whenSearchDisabledAndOptionsEmpty_shouldShowEmptyStateWithoutSearchBar() throws {
        let pickerViewController = FormPickerSearchViewController<FormPickerElement>(
            title: "Installments",
            configuration: .init(isSearchEnabled: false),
            options: []
        ) { _ in
            XCTFail("Selection handler should not be called")
        }

        setupRootViewController(pickerViewController)

        let searchViewController = try XCTUnwrap(
            pickerViewController.viewControllers.first as? SearchViewController
        )

        XCTAssertFalse(searchViewController.searchBar.isDescendant(of: searchViewController.view))
        XCTAssertFalse(searchViewController.emptyView.isHidden)
        XCTAssertEqual(searchViewController.emptyView.searchTerm, "")
        XCTAssertTrue(searchViewController.resultsListViewController.view.isHidden)
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

    func test_pickerHeader_whenLaidOut_shouldHugContentHeight() throws {
        let searchViewController = try makeSearchViewController(
            configuration: .init(header: .init(title: "Installments"))
        )
        let headerView = try XCTUnwrap(
            searchViewController.headerView as? FormPickerHeaderView
        )

        searchViewController.view.layoutIfNeeded()

        let compressedSize = headerView.systemLayoutSizeFitting(
            CGSize(
                width: headerView.bounds.width,
                height: UIView.layoutFittingCompressedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        XCTAssertEqual(
            headerView.bounds.height,
            compressedSize.height,
            accuracy: 0.5
        )
        XCTAssertGreaterThan(
            searchViewController.resultsListViewController.view.bounds.height,
            headerView.bounds.height
        )
    }

    // MARK: - Helpers

    private func makeSearchViewController(
        title: String? = nil,
        configuration: FormPickerConfiguration = .init(),
        theme: CheckoutTheme = .default,
        options: [FormPickerElement] = [
            .init(
                identifier: "Identifier",
                title: "Title",
                subtitle: "Subtitle"
            )
        ],
        selectedOption: FormPickerElement? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> SearchViewController {
        let pickerSearchViewController = FormPickerSearchViewController(
            title: title,
            configuration: configuration,
            theme: theme,
            options: options,
            selectedOption: selectedOption,
            selectionHandler: { _ in }
        )

        // Allow setup in viewDidLoad
        setupRootViewController(pickerSearchViewController)

        return try XCTUnwrap(
            pickerSearchViewController.viewControllers.first as? SearchViewController,
            file: file,
            line: line
        )
    }

    private func makeOptions() -> [FormPickerElement] {
        [
            .init(identifier: "first", title: "First", subtitle: "First subtitle"),
            .init(identifier: "second", title: "Second", subtitle: "Second subtitle")
        ]
    }
}
