//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public protocol SearchViewControllerEmptyView: UIView {
    var searchTerm: String { get set }
}

@_spi(AdyenInternal)
public class SearchViewController: UIViewController, AdyenObserver {

    private let viewModel: ViewModel
    internal let emptyView: SearchViewControllerEmptyView
    
    public lazy var resultsListViewController = ListViewController(style: viewModel.style)
    
    public init(
        viewModel: ViewModel,
        emptyView: SearchViewControllerEmptyView
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
        return loadingView
    }()
    
    internal lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = viewModel.searchBarPlaceholder
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = viewModel.style.backgroundColor
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
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
        view.addSubview(searchBar)
        
        setupConstraints()
        
        updateInterface(with: viewModel.interfaceState)
        observe(viewModel.$interfaceState) { [weak self] in
            self?.updateInterface(with: $0)
        }
        
        viewModel.handleViewDidLoad()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.shouldFocusSearchBarOnAppearance {
            searchBar.becomeFirstResponder()
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
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        loadingView.adyen.anchor(inside: self.view)
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
