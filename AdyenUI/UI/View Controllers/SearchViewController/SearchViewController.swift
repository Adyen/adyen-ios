//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Protocol specifying the interface of a view that is shown
/// when the results of the ``SearchViewController`` are empty.
package protocol SearchResultsEmptyView: UIView {
    /// The searchTerm that caused the search results to be empty
    ///
    /// Use this value to update your messaging
    var searchTerm: String { get set }
}

/// A view controller that shows search results in a ``ListViewController``
package class SearchViewController: UIViewController, AdyenObserver {

    private enum Layout {
        static let searchBarHorizontalInset: CGFloat = 8
        static let headerTopSpacing: CGFloat = 16
        static let headerBottomSpacing: CGFloat = 24
        static let footerSpacing: CGFloat = 16
    }

    internal lazy var keyboardObserver = KeyboardObserver()
    private var currentSearchText = ""
    private var isEndingSearch = false
    private var emptyViewBottomConstraint: NSLayoutConstraint?
    private var footerViewBottomConstraint: NSLayoutConstraint?

    internal let viewModel: ViewModel
    internal let emptyView: SearchResultsEmptyView
    internal let resultsHorizontalInset: CGFloat
    private let searchTextFieldToResultsSpacing: CGFloat?

    /// Optional view shown above the search bar (e.g. a title/description header).
    internal let headerView: UIView?

    /// Optional view pinned below the results, above the keyboard (e.g. a submit button).
    internal let footerView: UIView?
    
    /// Delegate to handle different viewController events.
    package weak var delegate: ViewControllerDelegate?
    
    package lazy var resultsListViewController = makeResultsListViewController()

    /// Displays each result in its own section when enabled.
    /// Configure before loading the view.
    package var separatesResultsIntoSections = false

    /// Whether the search bar is shown in the navigation bar and the header scrolls with the results.
    internal let usesLargeTitleLayout: Bool

    /// Holds the header as the results' table header when ``usesLargeTitleLayout`` is enabled.
    internal lazy var scrollingHeaderView = UIView()

    /// Shows the search bar in the navigation bar when ``usesLargeTitleLayout`` is enabled.
    internal lazy var searchController = makeSearchController()

    /// Initializes the search view controller.
    ///
    /// - Parameters:
    ///   - viewModel: The business logic of the search view controller
    ///   - emptyView: The view (conforming to ``SearchResultsEmptyView``) to show when the search results are empty.
    ///   - headerView: The view shown above the search bar.
    ///   - footerView: The view pinned below the results, above the keyboard.
    ///   - resultsHorizontalInset: The horizontal distance between the results and the view edges.
    ///   - searchTextFieldToResultsSpacing: The vertical distance between the search text field and results.
    ///   - usesLargeTitleLayout: Shows the search bar in the navigation bar, where it stays visible while scrolling,
    ///     and scrolls the header with the results, so a large navigation title can collapse.
    package init(
        viewModel: ViewModel,
        emptyView: SearchResultsEmptyView,
        headerView: UIView? = nil,
        footerView: UIView? = nil,
        resultsHorizontalInset: CGFloat = 0,
        searchTextFieldToResultsSpacing: CGFloat? = nil,
        usesLargeTitleLayout: Bool = false
    ) {
        self.emptyView = emptyView
        self.viewModel = viewModel
        self.headerView = headerView
        self.footerView = footerView
        self.resultsHorizontalInset = resultsHorizontalInset
        self.searchTextFieldToResultsSpacing = searchTextFieldToResultsSpacing
        self.usesLargeTitleLayout = usesLargeTitleLayout
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(style: .whiteLarge)
        loadingView.color = .Adyen.componentLoadingMessageColor
        loadingView.hidesWhenStopped = true
        loadingView.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        return loadingView
    }()
    
    internal lazy var searchBar: UISearchBar = {
        if usesLargeTitleLayout {
            return searchController.searchBar
        }
        return .prominent(
            placeholder: viewModel.searchBarPlaceholder,
            theme: viewModel.theme,
            delegate: self
        )
    }()

    override package func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = viewModel.theme.colors.background

        view.addSubview(loadingView)
        
        delegate?.viewDidLoad(viewController: self)
        
        if viewModel.shouldShowSearchBar {
            emptyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTapped)))
        }
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView)
        
        resultsListViewController.willMove(toParent: self)
        addChild(resultsListViewController)
        view.addSubview(resultsListViewController.view)
        resultsListViewController.didMove(toParent: self)
        resultsListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        headerView?.translatesAutoresizingMaskIntoConstraints = false

        if usesLargeTitleLayout {
            setupLargeTitleLayout()
        } else {
            if viewModel.shouldShowSearchBar {
                searchBar.setContentCompressionResistancePriority(.required, for: .vertical)
                searchBar.setContentHuggingPriority(.required, for: .vertical)
                view.addSubview(searchBar)
            }
            headerView.map(view.addSubview)
        }

        if let footerView {
            footerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(footerView)
        }
        
        setupConstraints()
        
        observe(keyboardObserver.$keyboardTransition) { [weak self] in
            self?.handleKeyboardTransitionDidChange($0)
        }
        
        updateInterface(with: viewModel.interfaceState)
        observe(viewModel.$interfaceState) { [weak self] in
            self?.updateInterface(with: $0)
        }
        
        viewModel.handleViewDidLoad()
    }
    
    override package func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutScrollingHeaderIfNeeded()
    }

    override package func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delegate?.viewWillAppear(viewController: self)
        hideNavigationBarHairline()
        
        if viewModel.shouldShowSearchBar,
           viewModel.shouldFocusSearchBarOnAppearance {
            DispatchQueue.main.async { // Fix animation glitch on iOS 17
                self.searchBar.becomeFirstResponder()
            }
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(viewController: self)
    }
    
    override package func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // The search field background is a rendered UIImage; re-bake it on appearance changes.
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection),
              viewModel.shouldShowSearchBar else { return }
        searchBar.adyenApplyFieldStyle(
            theme: viewModel.theme,
            isEditing: searchBar.isFirstResponder
        )
    }
    
    private func setupConstraints() {
        // With a large title, the results start at the top of the view, under the navigation bar, and the header is part of their content.
        let (resultsTopAnchor, resultsTopSpacing) = usesLargeTitleLayout
            ? (view.topAnchor, 0)
            : setupFixedHeaderConstraints()
        // The empty and loading views sit below the header, wherever it is.
        let placeholderTopAnchor = usesLargeTitleLayout ? scrollingHeaderView.bottomAnchor : resultsTopAnchor
        let placeholderTopSpacing = usesLargeTitleLayout ? 0 : resultsTopSpacing
        let (resultsBottomAnchor, resultsBottomSpacing) = setupFooterConstraints()
        // The large title layout insets the rows inside the table instead.
        let tableHorizontalInset = usesLargeTitleLayout ? 0 : resultsHorizontalInset

        NSLayoutConstraint.activate([
            resultsListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: tableHorizontalInset),
            resultsListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -tableHorizontalInset),
            resultsListViewController.view.topAnchor.constraint(equalTo: resultsTopAnchor, constant: resultsTopSpacing),
            resultsListViewController.view.bottomAnchor.constraint(equalTo: resultsBottomAnchor, constant: -resultsBottomSpacing),
            
            emptyView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: placeholderTopAnchor, constant: placeholderTopSpacing),
            
            loadingView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: placeholderTopAnchor, constant: placeholderTopSpacing),
            loadingView.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor)
        ])
        
        emptyViewBottomConstraint = emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        emptyViewBottomConstraint?.isActive = true
    }

    /// Activates the constraints of the header and the search bar shown above the results.
    ///
    /// - Returns: The anchor and spacing the results should start at.
    private func setupFixedHeaderConstraints() -> (anchor: NSLayoutYAxisAnchor, spacing: CGFloat) {

        let contentTopAnchor: NSLayoutYAxisAnchor
        let contentTopSpacing: CGFloat
        if let headerView {
            // Keep the header at its content height so the results list, not the header, absorbs extra vertical space.
            let headerHeightHug = headerView.heightAnchor.constraint(equalToConstant: 0)
            headerHeightHug.priority = .defaultLow
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: Layout.headerTopSpacing),
                headerView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                headerHeightHug
            ])
            contentTopAnchor = headerView.bottomAnchor
            contentTopSpacing = Layout.headerBottomSpacing
        } else {
            contentTopAnchor = view.layoutMarginsGuide.topAnchor
            contentTopSpacing = 0
        }

        let resultsTopAnchor: NSLayoutYAxisAnchor
        let resultsTopSpacing: CGFloat
        if viewModel.shouldShowSearchBar {
            NSLayoutConstraint.activate([
                searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.searchBarHorizontalInset),
                searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.searchBarHorizontalInset),
                searchBar.topAnchor.constraint(equalTo: contentTopAnchor, constant: contentTopSpacing)
            ])
            resultsTopAnchor = searchTextFieldToResultsSpacing == nil
                ? searchBar.bottomAnchor
                : searchBar.searchTextField.bottomAnchor
            resultsTopSpacing = searchTextFieldToResultsSpacing ?? 0
        } else {
            resultsTopAnchor = contentTopAnchor
            resultsTopSpacing = contentTopSpacing
        }
        
        return (resultsTopAnchor, resultsTopSpacing)
    }
    
    private func updateInterface(with interfaceState: InterfaceState) {
        
        emptyView.isHidden = true
        loadingView.stopAnimating()
        // The header is part of the results, so they stay visible to keep it on screen.
        resultsListViewController.view.isHidden = !usesLargeTitleLayout
        
        switch interfaceState {
            
        case .loading:
            loadingView.startAnimating()
            
        case let .empty(searchTerm):
            emptyView.isHidden = false
            emptyView.searchTerm = searchTerm
            if usesLargeTitleLayout {
                resultsListViewController.reload(newSections: [])
            }
            
        case let .showingResults(results):
            let sections = separatesResultsIntoSections
                ? results.map { ListSection(items: [$0]) }
                : [ListSection(items: results)]

            resultsListViewController.reload(newSections: sections)
            resultsListViewController.view.isHidden = false
        }
    }
    
    override package var preferredContentSize: CGSize {
        get {
            guard resultsListViewController.isViewLoaded else { return .zero }
            let innerSize = resultsListViewController.preferredContentSize
            return CGSize(
                width: innerSize.width,
                height: .greatestFiniteMagnitude
            )
        }

        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns content size of scroll view.
        setter - no implemented.
        """) }
    }
    
    private func hideNavigationBarHairline() {
        let appearance = navigationController?.navigationBar.standardAppearance.copy() ?? UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = viewModel.theme.colors.background
        appearance.shadowColor = .clear
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }

    @objc
    private func dismissKeyboardTapped() {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Results & Header

extension SearchViewController {

    /// Reloads the results for the current search text, for example after the state of the results changed.
    package func reloadResults() {
        viewModel.handleSearchTextDidChange(currentSearchText)
    }

    /// Dismisses the keyboard and ends the active search, keeping the search text and its results.
    package func endSearch() {
        searchBar.resignFirstResponder()
        guard usesLargeTitleLayout, searchController.isActive else { return }
        let searchText = searchBar.text
        isEndingSearch = true
        searchController.isActive = false
        isEndingSearch = false
        searchBar.text = searchText
    }

    /// Requests the results for the search text, unless they were already requested for it.
    internal func updateSearchText(_ searchText: String) {
        guard searchText != currentSearchText else { return }
        currentSearchText = searchText
        viewModel.handleSearchTextDidChange(searchText)
    }
}

// MARK: - Footer & Keyboard

private extension SearchViewController {

    /// Activates the footer constraints, if a footer is set.
    ///
    /// - Returns: The anchor and spacing the results should end at.
    func setupFooterConstraints() -> (anchor: NSLayoutYAxisAnchor, spacing: CGFloat) {
        guard let footerView else { return (view.bottomAnchor, 0) }

        let footerViewBottomConstraint = footerView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -Layout.footerSpacing
        )
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            footerViewBottomConstraint
        ])
        self.footerViewBottomConstraint = footerViewBottomConstraint
        return (footerView.topAnchor, Layout.footerSpacing)
    }

    func handleKeyboardTransitionDidChange(_ transition: KeyboardTransition) {
        
        let updateConstraint: () -> Void = {
            let keyboardHeight = transition.keyboardRect.height
            self.emptyViewBottomConstraint?.constant = -keyboardHeight
            // The footer is pinned to the safe area, which the keyboard already overlaps at the bottom.
            let footerKeyboardOffset = max(0, keyboardHeight - self.view.safeAreaInsets.bottom)
            self.footerViewBottomConstraint?.constant = -(Layout.footerSpacing + footerKeyboardOffset)
        }
        
        guard view.window != nil else {
            updateConstraint()
            return
        }
        
        self.view.setNeedsLayout()
        UIView.animate(
            withDuration: transition.animationDuration,
            delay: 0,
            options: transition.animationOptions.union(.beginFromCurrentState),
            animations: {
                updateConstraint()
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    package func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchText(searchText)
    }
    
    package func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.adyenApplyFieldStyle(theme: viewModel.theme, isEditing: true)
    }
    
    package func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.adyenApplyFieldStyle(theme: viewModel.theme, isEditing: false)
    }
    
    package func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UISearchResultsUpdating {

    package func updateSearchResults(for searchController: UISearchController) {
        guard !isEndingSearch else { return }
        updateSearchText(searchController.searchBar.text ?? "")
    }
}
