//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Foundation

@_spi(AdyenInternal)
public protocol SearchViewControllerDelegate: AnyObject {
    
    func textDidChange(_ searchBar: UISearchBar, searchText: String)
}

@_spi(AdyenInternal)
public class SearchViewController: UIViewController {
    
    private let childViewController: UIViewController
    
    public init(childViewController: UIViewController, delegate: SearchViewControllerDelegate) {
        self.childViewController = childViewController
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Search..."
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private weak var delegate: SearchViewControllerDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchBar)
        childViewController.willMove(toParent: self)
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
            searchBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0),
            searchBar.bottomAnchor.constraint(equalTo: childViewController.view.layoutMarginsGuide.topAnchor, constant: 0),
            childViewController.view.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            childViewController.view.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
            childViewController.view.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0)
        ])
    }

    override public var preferredContentSize: CGSize {
        get {
            guard childViewController.isViewLoaded else { return .zero }
            let innerSize = childViewController.preferredContentSize
            return CGSize(width: innerSize.width,
                          height: searchBar.bounds.height + innerSize.height + (1.0 / UIScreen.main.scale)) }
        
        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns content size of scroll view.
        setter - no implemented.
        """) }
    }

}

extension SearchViewController: UISearchBarDelegate {

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.textDidChange(searchBar, searchText: searchText)
    }

}
