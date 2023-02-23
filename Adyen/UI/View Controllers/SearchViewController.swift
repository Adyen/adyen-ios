//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public protocol SearchViewControllerDelegate: AnyObject {

    func textDidChange(_ searchBar: UISearchBar, searchText: String)
}

@_spi(AdyenInternal)
public class SearchViewController: UIViewController {

    internal let childViewController: UIViewController
    private let localizationParameters: LocalizationParameters?
    private let style: ViewStyle

    public init(childViewController: UIViewController,
                style: ViewStyle,
                delegate: SearchViewControllerDelegate,
                localizationParameters: LocalizationParameters? = nil) {
        self.childViewController = childViewController
        self.style = style
        self.delegate = delegate
        self.localizationParameters = localizationParameters
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = localizedString(.searchPlaceholder, localizationParameters)
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = style.backgroundColor
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "search",
                                  in: Bundle.coreInternalResources,
                                  compatibleWith: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.setContentHuggingPriority(.required, for: .vertical)

        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2).adyen.font(with: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

        return titleLabel
    }()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.text = localizedString(.paybybankSubtitle, localizationParameters)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 0

        return subtitleLabel
    }()

    // MARK: - Stack View

    private lazy var noResultsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setCustomSpacing(32.0, after: imageView)
        stackView.setCustomSpacing(4.0, after: titleLabel)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill

        return stackView
    }()

    private weak var delegate: SearchViewControllerDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = style.backgroundColor
        view.addSubview(searchBar)
        view.addSubview(noResultsStackView)
        noResultsStackView.isHidden = true
        childViewController.willMove(toParent: self)
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
            searchBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0),

            noResultsStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
            noResultsStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            noResultsStackView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),

            childViewController.view.topAnchor.constraint(equalTo: searchBar.layoutMarginsGuide.bottomAnchor, constant: 10),
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
                          height: UIScreen.main.bounds.height * 0.7)
        }

        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns content size of scroll view.
        setter - no implemented.
        """) }
    }

    public func showNoSearchResultsView(searchText: String) {
        titleLabel.text = localizedString(.paybybankTitle, localizationParameters) + " '\(searchText)'"
        noResultsStackView.isHidden = false
        childViewController.view.isHidden = true
    }

    private func hideNoSearchResultsView() {
        noResultsStackView.isHidden = true
        childViewController.view.isHidden = false
    }

}

@_spi(AdyenInternal)
extension SearchViewController: UISearchBarDelegate {

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        hideNoSearchResultsView()
        delegate?.textDidChange(searchBar, searchText: searchText)
    }
}
