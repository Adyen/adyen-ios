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
        static let headerBottomSpacing: CGFloat = 8
    }

    internal lazy var keyboardObserver = KeyboardObserver()
    private var emptyViewBottomConstraint: NSLayoutConstraint?

    internal let viewModel: ViewModel
    internal let emptyView: SearchResultsEmptyView

    /// Optional view shown above the search bar (e.g. a title/description header).
    internal let headerView: UIView?
    
    /// Delegate to handle different viewController events.
    package weak var delegate: ViewControllerDelegate?
    
    package lazy var resultsListViewController = ListViewController(style: viewModel.style)

    /// Initializes the search view controller.
    ///
    /// - Parameters:
    ///   - viewModel: The business logic of the search view controller
    ///   - emptyView: The view (conforming to ``SearchResultsEmptyView``) to show when the search results are empty.
    package init(
        viewModel: ViewModel,
        emptyView: SearchResultsEmptyView,
        headerView: UIView? = nil
    ) {
        self.emptyView = emptyView
        self.viewModel = viewModel
        self.headerView = headerView
        
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
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        return loadingView
    }()
    
    internal lazy var searchBar: UISearchBar = {
        .prominent(
            placeholder: viewModel.searchBarPlaceholder,
            backgroundColor: viewModel.style.backgroundColor,
            delegate: self
        )
    }()

    override package func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = viewModel.style.backgroundColor

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
        
        if viewModel.shouldShowSearchBar {
            searchBar.setContentCompressionResistancePriority(.required, for: .vertical)
            searchBar.setContentHuggingPriority(.required, for: .vertical)
            view.addSubview(searchBar)
        }

        if let headerView {
            headerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(headerView)
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
    
    override package func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delegate?.viewWillAppear(viewController: self)
        
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
    
    private func setupConstraints() {

        let contentTopAnchor: NSLayoutYAxisAnchor
        let contentTopSpacing: CGFloat
        if let headerView {
            // Keep the header at its content height so the results list, not the header, absorbs extra vertical space.
            let headerHeightHug = headerView.heightAnchor.constraint(equalToConstant: 0)
            headerHeightHug.priority = .defaultLow
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
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
            resultsTopAnchor = searchBar.bottomAnchor
            resultsTopSpacing = 0
        } else {
            resultsTopAnchor = contentTopAnchor
            resultsTopSpacing = contentTopSpacing
        }
        
        NSLayoutConstraint.activate([
            resultsListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsListViewController.view.topAnchor.constraint(equalTo: resultsTopAnchor, constant: resultsTopSpacing),
            resultsListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            emptyView.topAnchor.constraint(equalTo: resultsTopAnchor, constant: resultsTopSpacing),
            
            loadingView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: resultsTopAnchor, constant: resultsTopSpacing),
            loadingView.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor)
        ])
        
        emptyViewBottomConstraint = emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        emptyViewBottomConstraint?.isActive = true
    }
    
    private func updateInterface(with interfaceState: InterfaceState) {
        
        emptyView.isHidden = true
        loadingView.stopAnimating()
        resultsListViewController.view.isHidden = true
        
        switch interfaceState {
            
        case .loading:
            loadingView.startAnimating()
            
        case let .empty(searchTerm):
            emptyView.isHidden = false
            emptyView.searchTerm = searchTerm
            
        case let .showingResults(results):
            resultsListViewController.reload(
                newSections: [.init(items: results)]
            )
            resultsListViewController.view.isHidden = false
        }
    }
    
    private func handleKeyboardTransitionDidChange(_ transition: KeyboardTransition) {
        
        let updateConstraint: () -> Void = {
            self.emptyViewBottomConstraint?.constant = -transition.keyboardRect.height
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
    
    @objc
    private func dismissKeyboardTapped() {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    package func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.handleSearchTextDidChange(searchText)
    }
    
    package func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
