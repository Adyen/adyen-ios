//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Protocol specifying the interface of a view that is shown
/// when the results of the ``SearchViewController`` are empty.
@_spi(AdyenInternal)
public protocol SearchResultsEmptyView: UIView {
    /// The searchTerm that caused the search results to be empty
    ///
    /// Use this value to update your messaging
    var searchTerm: String { get set }
}

/// A view controller that shows search results in a ``ListViewController``
@_spi(AdyenInternal)
public class SearchViewController: UIViewController, AdyenObserver {
    
    internal lazy var keyboardObserver = KeyboardObserver()
    private var emptyViewBottomConstraint: NSLayoutConstraint?

    internal let viewModel: ViewModel
    internal let emptyView: SearchResultsEmptyView
    
    public lazy var resultsListViewController = ListViewController(style: viewModel.style)
    
    /// Initializes the search view controller.
    ///
    /// - Parameters:
    ///   - viewModel: The business logic of the search view controller
    ///   - emptyView: The view (conforming to ``SearchResultsEmptyView``) to show when the search results are empty.
    public init(
        viewModel: ViewModel,
        emptyView: SearchResultsEmptyView
    ) {
        self.emptyView = emptyView
        self.viewModel = viewModel
        
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

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = viewModel.style.backgroundColor

        view.addSubview(loadingView)
        
        emptyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTapped)))
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView)
        
        resultsListViewController.willMove(toParent: self)
        addChild(resultsListViewController)
        view.addSubview(resultsListViewController.view)
        resultsListViewController.didMove(toParent: self)
        resultsListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.setContentCompressionResistancePriority(.required, for: .vertical)
        searchBar.setContentHuggingPriority(.required, for: .vertical)
        view.addSubview(searchBar)
        
        setupConstraints()
        
        observe(keyboardObserver.$keyboardRect) { [weak self] in
            self?.handleKeyboardHeightDidChange(keyboardHeight: $0.height)
        }
        
        updateInterface(with: viewModel.interfaceState)
        observe(viewModel.$interfaceState) { [weak self] in
            self?.updateInterface(with: $0)
        }
        
        viewModel.handleViewDidLoad()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.shouldFocusSearchBarOnAppearance {
            DispatchQueue.main.async { // Fix animation glitch on iOS 17
                self.searchBar.becomeFirstResponder()
            }
        }
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0),

            resultsListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            resultsListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            resultsListViewController.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            resultsListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            emptyView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
            emptyView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            emptyView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            
            loadingView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
            loadingView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            loadingView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            loadingView.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor, constant: 0)
        ])
        
        emptyViewBottomConstraint = emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
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
    
    private func handleKeyboardHeightDidChange(keyboardHeight: CGFloat) {
        
        let updateConstraint: () -> Void = {
            self.emptyViewBottomConstraint?.constant = -keyboardHeight
        }
        
        guard view.window != nil else {
            updateConstraint()
            return
        }
        
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
            updateConstraint()
            self.view.layoutIfNeeded()
        }
    }

    override public var preferredContentSize: CGSize {
        get {
            guard resultsListViewController.isViewLoaded else { return .zero }
            let innerSize = resultsListViewController.preferredContentSize
            return CGSize(width: innerSize.width,
                          height: .greatestFiniteMagnitude)
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
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.handleSearchTextDidChange(searchText)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
