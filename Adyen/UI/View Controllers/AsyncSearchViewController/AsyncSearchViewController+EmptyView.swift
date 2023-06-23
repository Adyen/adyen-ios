//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension AsyncSearchViewController {
    
    internal class EmptyView: UIStackView {
        
        private let localizationParameters: LocalizationParameters?
        public var searchTerm: String {
            didSet { updateLabels() }
        }
        
        private lazy var titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.font = UIFont.preferredFont(forTextStyle: .title2).adyen.font(with: .bold)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
            return titleLabel
        }()

        private lazy var subtitleLabel: UILabel = {
            let subtitleLabel = UILabel()
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.numberOfLines = 0
            subtitleLabel.textAlignment = .center
            return subtitleLabel
        }()

        // MARK: - Stack View

        internal init(
            searchTerm: String,
            localizationParameters: LocalizationParameters? = nil
        ) {
            self.localizationParameters = localizationParameters
            self.searchTerm = searchTerm
            
            super.init(frame: .zero)
            
            addArrangedSubview(titleLabel)
            setCustomSpacing(4.0, after: titleLabel)
            
            addArrangedSubview(subtitleLabel)
            
            translatesAutoresizingMaskIntoConstraints = false
            axis = .vertical
            alignment = .center
            distribution = .fill
            
            updateLabels()
        }
        
        @available(*, unavailable)
        internal required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

private extension AsyncSearchViewController.EmptyView {
    
    func updateLabels() {
        // TODO: Make Generic
        // TODO: Make "manual address entry" tappable and add a handler
        
        if searchTerm.isEmpty {
            titleLabel.text = "Enter your address"
            subtitleLabel.text = "or use manual address entry"
        } else {
            titleLabel.text = "No results found"
            subtitleLabel.text = "‘\(searchTerm)’ did not match with anything, try again or use manual address entry"
        }
    }
}
