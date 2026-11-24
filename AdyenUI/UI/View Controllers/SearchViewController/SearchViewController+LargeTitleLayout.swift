//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

private enum LargeTitleLayout {
    static let headerTopSpacing: CGFloat = 12
    static let headerTopSpacingBelowSearchBar: CGFloat = 0
    static let headerBottomSpacing: CGFloat = 24
}

// MARK: - Large Title Layout

extension SearchViewController {

    /// Updates the layout after the header's content changed.
    ///
    /// - Parameter revealingHeader: Whether to scroll the results to the top so the header is visible.
    package func updateHeaderLayout(revealingHeader: Bool = false) {
        guard isViewLoaded else { return }
        view.setNeedsLayout()
        view.layoutIfNeeded()

        guard revealingHeader, usesLargeTitleLayout else { return }
        let tableView: UITableView = resultsListViewController.tableView
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.adjustedContentInset.top), animated: true)
    }

    internal func makeResultsListViewController() -> ListViewController {
        // A large title only collapses when the scroll view spans the navigation bar's width,
        // so the large title layout insets the rows inside a full-width table instead.
        let listViewController = ListViewController(style: viewModel.style, theme: viewModel.theme)
        if usesLargeTitleLayout {
            listViewController.rowHorizontalInset = resultsHorizontalInset
        }
        return listViewController
    }

    internal func makeSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchResultsUpdater = self

        let searchBar = searchController.searchBar
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = viewModel.searchBarPlaceholder
        searchBar.delegate = self
        searchBar.adyenApplyFieldStyle(theme: viewModel.theme, isEditing: false)
        return searchController
    }

    /// Places the header in the results' table header and the search bar in the navigation bar,
    /// and lets the navigation bar track the results.
    internal func setupLargeTitleLayout() {
        navigationItem.largeTitleDisplayMode = .never

        if let headerView {
            scrollingHeaderView.addSubview(headerView)
            let headerTopSpacing = viewModel.shouldShowSearchBar
                ? LargeTitleLayout.headerTopSpacingBelowSearchBar
                : LargeTitleLayout.headerTopSpacing
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: scrollingHeaderView.topAnchor, constant: headerTopSpacing),
                headerView.leadingAnchor.constraint(equalTo: scrollingHeaderView.leadingAnchor, constant: resultsHorizontalInset),
                headerView.trailingAnchor.constraint(equalTo: scrollingHeaderView.trailingAnchor, constant: -resultsHorizontalInset),
                scrollingHeaderView.bottomAnchor.constraint(
                    equalTo: headerView.bottomAnchor,
                    constant: LargeTitleLayout.headerBottomSpacing
                )
            ])
        }

        if viewModel.shouldShowSearchBar {
            navigationItem.searchController = searchController
            // Pin the search bar below the title. From iOS 26, iPhone otherwise places it in the bottom toolbar.
            navigationItem.preferredSearchBarPlacement = .stacked
            navigationItem.hidesSearchBarWhenScrolling = false
            if #available(iOS 26.0, *) {
                navigationItem.searchBarPlacementAllowsToolbarIntegration = false
            }
            definesPresentationContext = true
        }

        // The empty and loading views are positioned below the header, on top of the results.
        view.bringSubviewToFront(emptyView)
        view.bringSubviewToFront(loadingView)

        resultsListViewController.tableView.tableHeaderView = scrollingHeaderView
        setContentScrollView(resultsListViewController.tableView, for: .top)
    }

    /// Sizes the table header to fit its content, which `UITableView` doesn't do for Auto Layout content.
    internal func layoutScrollingHeaderIfNeeded() {
        guard usesLargeTitleLayout else { return }
        let tableView: UITableView = resultsListViewController.tableView
        let width = tableView.bounds.width
        guard width > 0 else { return }

        let height = scrollingHeaderView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        guard scrollingHeaderView.frame.size != CGSize(width: width, height: height) else { return }

        scrollingHeaderView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        // Reassigning makes the table apply the new height.
        tableView.tableHeaderView = scrollingHeaderView
    }
}
