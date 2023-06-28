//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public protocol AsyncSearchViewControllerEmptyView: UIView {
    var searchTerm: String { get set }
}

@_spi(AdyenInternal)
public class AsyncSearchViewController: UIViewController, UISearchBarDelegate {

    public typealias ResultProvider = (_ searchTerm: String, _ handler: @escaping ([ListItem]) -> Void) -> Void
    
    private enum InterfaceState {
        case loading
        case empty(searchTerm: String)
        case showingResults(results: [ListItem])
    }
    
    private let style: ViewStyle
    private let searchBarPlaceholder: String?
    private var interfaceState: InterfaceState = .empty(searchTerm: "") {
        didSet { updateInterface() }
    }

    private lazy var resultsListViewController = ListViewController(style: style)
    
    private let resultProvider: ResultProvider
    
    public init(
        style: ViewStyle,
        searchBarPlaceholder: String? = nil,
        emptyView: AsyncSearchViewControllerEmptyView,
        localizationParameters: LocalizationParameters? = nil,
        resultProvider: @escaping ResultProvider
    ) {
        self.style = style
        self.searchBarPlaceholder = searchBarPlaceholder ?? localizedString(.searchPlaceholder, localizationParameters)
        self.emptyView = emptyView
        self.resultProvider = resultProvider
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = searchBarPlaceholder
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = style.backgroundColor
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let emptyView: AsyncSearchViewControllerEmptyView
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(style: .whiteLarge)
        if #available(iOS 13.0, *) {
            loadingView.color = .secondarySystemFill
        }
        loadingView.hidesWhenStopped = true
        return loadingView
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = style.backgroundColor
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        view.addSubview(loadingView)
        view.addSubview(emptyView)
        
        resultsListViewController.willMove(toParent: self)
        addChild(resultsListViewController)
        view.addSubview(resultsListViewController.view)
        resultsListViewController.didMove(toParent: self)
        resultsListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.setContentCompressionResistancePriority(.required, for: .vertical)
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0),

            resultsListViewController.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            resultsListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            resultsListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            resultsListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            emptyView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
            emptyView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            emptyView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor)
        ])
        
        loadingView.adyen.anchor(inside: view)
        
        updateInterface()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
    
    private func updateInterface() {
        
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
    
    // MARK: - UISearchBarDelegate
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        interfaceState = .loading
        
        // Even with an empty search text we call the result provider to provide a way to cancel any requests if needed
        resultProvider(searchText) { [weak self] results in
            guard let self else { return }
            
            if !results.isEmpty {
                interfaceState = .showingResults(results: results)
                return
            }
            
            interfaceState = .empty(searchTerm: searchText)
        }
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
