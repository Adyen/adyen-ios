//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension FormPickerSearchViewController {
    
    /// The view that is shown when the form picker search result is empty
    public class EmptyView: EmptyStateView<UILabel> {
        
        override public var searchTerm: String {
            didSet { updateLabels() }
        }
        
        /// Initializes the `EmptyView` for the ``FormPickerSearchViewController``
        ///
        /// - Parameters:
        ///   - searchTerm: The search term that caused an empty state.
        ///   - style: The style of the view.
        ///   - localizationParameters: The localization parameters.
        internal init(
            searchTerm: String = "",
            style: EmptyStateStyle = .init(),
            localizationParameters: LocalizationParameters? = nil
        ) {
            super.init(
                searchTerm: searchTerm,
                subtitleLabel: Self.setupSubtitleLabel(),
                style: style,
                localizationParameters: localizationParameters
            )
            
            subtitleLabel.adyen.apply(style.subtitle)
        }
        
        @available(*, unavailable)
        internal required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private static func setupSubtitleLabel() -> UILabel {
            let subtitleLabel = UILabel()
            subtitleLabel.numberOfLines = 0
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
            return subtitleLabel
        }
        
        private func updateLabels() {
            titleLabel.text = localizedString(.pickerSearchEmptyTitle, localizationParameters)
            subtitleLabel.text = localizedString(.pickerSearchEmptySubtitle, localizationParameters, searchTerm)
        }
    }
}
