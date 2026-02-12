//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension AddressLookupSearchViewController {
    
    /// The view that is shown when the address lookup search result is empty
    internal class EmptyView: EmptyStateView<LinkTextView> {
        
        override public var searchTerm: String {
            didSet { updateLabels() }
        }
        
        /// Initializes the `EmptyView` for the ``AddressLookupSearchViewController``
        ///
        /// - Parameters:
        ///   - searchTerm: The search term that caused an empty state.
        ///   - style: The style of the view.
        ///   - localizationParameters: The localization parameters.
        ///   - dismissHandler: A closure that is called when manual entry is requested.
        internal init(
            searchTerm: String = "",
            style: EmptyStateViewStyle = .init(),
            localizationParameters: LocalizationParameters? = nil,
            dismissHandler: @escaping () -> Void
        ) {
            super.init(
                searchTerm: searchTerm,
                subtitleLabel: Self.setupSubtitleLabel(with: dismissHandler),
                style: style,
                localizationParameters: localizationParameters
            )
            
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
    
    private static func setupSubtitleLabel(with dismissHandler: @escaping () -> Void) -> LinkTextView {
        let textView = LinkTextView { _ in
            dismissHandler()
        }
        textView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "textView")
        return textView
    }
    
    func updateLabels() {
        if searchTerm.isEmpty {
            titleLabel.text = localizedString(.addressLookupSearchEmptyTitle, localizationParameters)
        } else {
            titleLabel.text = localizedString(.addressLookupSearchEmptyTitleNoResults, localizationParameters)
        }
        
        configureSubtitleLabel(for: searchTerm)
    }
    
    func configureSubtitleLabel(for searchTerm: String) {

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
