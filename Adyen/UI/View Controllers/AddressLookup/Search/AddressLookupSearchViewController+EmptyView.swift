//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension AddressLookupSearchViewController {
    
    /// The view that is shown when the address lookup search result is empty
    internal class EmptyView: UIView, SearchResultsEmptyView {
        
        private let style: AddressLookupSearchEmptyStyle
        private let localizationParameters: LocalizationParameters?
        private let dismissHandler: () -> Void
        
        public var searchTerm: String {
            didSet { updateLabels() }
        }
        
        private lazy var titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
            return titleLabel
        }()
        
        private lazy var subtitleLabel: LinkTextView = {
            let textView = LinkTextView { [weak self] _ in
                self?.dismissHandler()
            }
            textView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "textView")
            return textView
        }()
        
        /// Initializes the `EmptyView` for the ``AddressLookupSearchViewController``
        ///
        /// - Parameters:
        ///   - searchTerm: The search term that caused an empty state.
        ///   - style: The style of the view.
        ///   - localizationParameters: The localization parameters.
        ///   - dismissHandler: A closure that is called when manual entry is requested.
        internal init(
            searchTerm: String = "",
            style: AddressLookupSearchEmptyStyle = .init(),
            localizationParameters: LocalizationParameters? = nil,
            dismissHandler: @escaping () -> Void
        ) {
            self.style = style
            self.localizationParameters = localizationParameters
            self.searchTerm = searchTerm
            self.dismissHandler = dismissHandler
            
            super.init(frame: .zero)
            
            setupContent()
            updateLabels()
        }
        
        @available(*, unavailable)
        internal required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Updating Interface

private extension AddressLookupSearchViewController.EmptyView {
    
    func setupContent() {
        let contentStack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                subtitleLabel
            ]
        )
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.distribution = .fill
        addSubview(contentStack)
        
        contentStack.setCustomSpacing(4.0, after: titleLabel)
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -16),
            contentStack.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor, constant: 0)
        ])
    }
    
    func updateLabels() {
        if searchTerm.isEmpty {
            titleLabel.text = localizedString(.addressLookupSearchEmptyTitle, localizationParameters)
        } else {
            titleLabel.text = localizedString(.addressLookupSearchEmptyTitleNoResults, localizationParameters)
        }
        
        titleLabel.textColor = style.title.color
        subtitleLabel.textColor = style.subtitle.color
        
        titleLabel.font = style.title.font
        subtitleLabel.font = style.subtitle.font
        
        configureSubtitleLabel(for: searchTerm)
    }
    
    private func configureSubtitleLabel(for searchTerm: String) {

        let subtitle: String = {
            if searchTerm.isEmpty {
                return localizedString(.addressLookupSearchEmptySubtitle, localizationParameters)
            } else {
                return localizedString(.addressLookupSearchEmptySubtitleNoResults, localizationParameters, searchTerm)
            }
        }()

        subtitleLabel.update(
            text: subtitle,
            style: style.subtitle,
            linkRangeDelimiter: "#"
        )
    }
}
