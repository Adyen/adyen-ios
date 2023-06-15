//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public class AsyncSearchViewController: UIViewController, UISearchBarDelegate {

    public typealias ResultProvider = (_ searchTerm: String, _ handler: @escaping ([ListItem]) -> Void) -> Void
    
    private enum InterfaceState {
        case initial
        case loading
        case noEntries(searchTerm: String)
        case showingResults(results: [ListItem])
    }
    
    private let localizationParameters: LocalizationParameters?
    private let style: ViewStyle
    private let searchBarPlaceholder: String?
    private var interfaceState: InterfaceState = .initial {
        didSet {
            updateInterface()
        }
    }

    private lazy var resultsListViewController = ListViewController(style: style)
    
    // Debounced search
    private var searchTask: DispatchWorkItem? // TODO: Better put this inside a searchbar
    
    private let resultProvider: ResultProvider
    
    public init(
        style: ViewStyle,
        searchBarPlaceholder: String? = nil,
        localizationParameters: LocalizationParameters? = nil,
        resultProvider: @escaping ResultProvider
    ) {
        self.style = style
        self.searchBarPlaceholder = searchBarPlaceholder
        self.localizationParameters = localizationParameters
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
        searchBar.placeholder = searchBarPlaceholder ?? localizedString(.searchPlaceholder, localizationParameters)
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = style.backgroundColor
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private var emptyView: EmptyView? {
        willSet {
            emptyView?.removeFromSuperview()
        }
        didSet {
            guard let emptyView else { return }
            view.addSubview(emptyView)
            
            // TODO: This doesn't feel ideal doing it here - maybe custom function?
            
            NSLayoutConstraint.activate([
                emptyView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
                emptyView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
                emptyView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor)
            ])
        }
    }
    
    private var loadingView: UIActivityIndicatorView? {
        willSet {
            loadingView?.removeFromSuperview()
        }
        didSet {
            guard let loadingView else { return }
            view.addSubview(loadingView)
            
            // TODO: This doesn't feel ideal doing it here - maybe custom function?
            
            if #available(iOS 13.0, *) {
                loadingView.color = .secondarySystemFill
            }
            
            loadingView.adyen.anchor(inside: view.layoutMarginsGuide)
            
            loadingView.startAnimating()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = style.backgroundColor
        view.addSubview(searchBar)
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        resultsListViewController.willMove(toParent: self)
        addChild(resultsListViewController)
        view.addSubview(resultsListViewController.view)
        resultsListViewController.didMove(toParent: self)
        resultsListViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0),

            resultsListViewController.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            resultsListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            resultsListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            resultsListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
    
    private func updateInterface() {
        
        switch interfaceState {
        case .initial:
            emptyView = nil
            loadingView = nil
            resultsListViewController.view.isHidden = true
            
        case .loading:
            emptyView = nil
            loadingView = UIActivityIndicatorView(style: .whiteLarge)
            resultsListViewController.view.isHidden = true
            
        case let .noEntries(searchTerm):
            emptyView = EmptyView(
                searchTerm: searchTerm,
                localizationParameters: localizationParameters
            )
            loadingView = nil
            resultsListViewController.view.isHidden = true
            
        case let .showingResults(results):
            emptyView = nil
            loadingView = nil
            resultsListViewController.reload(
                newSections: [.init(items: results)]
            )
            resultsListViewController.view.isHidden = false
            print(results)
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        interfaceState = .loading
        
        // TODO: Discussion - We should not interfer with delaying anything - it's up to the merchant to cancel or not start network calls (Give examples, like: https://stackoverflow.com/questions/42444310/live-search-throttle-in-swift-3/48666001#48666001)
        
        // Even with an empty search text we call the result provider to provide a way to cancel any requests if needed
        resultProvider(searchText) { [weak self] results in
            guard let self else { return }
            
            if !results.isEmpty {
                interfaceState = .showingResults(results: results)
                return
            }
            
            interfaceState = searchText.isEmpty ?
                .initial :
                .noEntries(searchTerm: searchText)
        }
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
