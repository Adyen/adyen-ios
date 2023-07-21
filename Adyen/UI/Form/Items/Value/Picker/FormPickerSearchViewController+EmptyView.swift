//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension FormPickerSearchViewController {
    
    /// The view that is shown when the form picker search result is empty
    public class EmptyView: UIView, SearchResultsEmptyView {
        
        private let style: Style
        private let localizationParameters: LocalizationParameters?
        
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
        
        private lazy var subtitleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
            return titleLabel
        }()
        
        /// Initializes the `EmptyView` for the ``FormPickerSearchViewController``
        ///
        /// - Parameters:
        ///   - searchTerm: The search term that caused an empty state.
        ///   - style: The style of the view.
        ///   - localizationParameters: The localization parameters.
        internal init(
            searchTerm: String = "",
            style: Style = .init(),
            localizationParameters: LocalizationParameters? = nil
        ) {
            self.style = style
            self.localizationParameters = localizationParameters
            self.searchTerm = searchTerm
            
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

private extension FormPickerSearchViewController.EmptyView {
    
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
        titleLabel.text = localizedString(.pickerSearchEmptyTitle, localizationParameters)
        subtitleLabel.text = localizedString(.pickerSearchEmptySubtitle, localizationParameters, searchTerm)
        
        titleLabel.textColor = style.title.color
        subtitleLabel.textColor = style.subtitle.color
        
        titleLabel.font = style.title.font
        subtitleLabel.font = style.subtitle.font
    }
}
