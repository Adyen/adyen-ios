//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The style of the empty state view
public struct EmptyStateViewStyle: ViewStyle {
    
    public var title: TextStyle = .init(
        font: .preferredFont(forTextStyle: .headline),
        color: .Adyen.componentLabel
    )
    public var subtitle: TextStyle = .init(
        font: .preferredFont(forTextStyle: .subheadline),
        color: .Adyen.componentSecondaryLabel
    )
    public var backgroundColor: UIColor = .Adyen.componentBackground
}

/// A generic empty view with title and generic subtitle
@_spi(AdyenInternal)
public class EmptyStateView<SubtitleLabel: UIView>: UIView, SearchResultsEmptyView {
    
    internal let style: EmptyStateViewStyle
    internal let localizationParameters: LocalizationParameters?
    
    public var searchTerm: String
    
    internal lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return titleLabel
    }()
    
    internal let subtitleLabel: SubtitleLabel
    
    /// Initializes the `EmptyView` for the ``FormPickerSearchViewController``
    ///
    /// - Parameters:
    ///   - searchTerm: The search term that caused an empty state.
    ///   - subtitleLabel: The view to be used as a subtitle
    ///   - style: The style of the view.
    ///   - localizationParameters: The localization parameters.
    internal init(
        searchTerm: String = "",
        subtitleLabel: SubtitleLabel,
        style: EmptyStateViewStyle = .init(),
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.style = style
        self.localizationParameters = localizationParameters
        self.searchTerm = searchTerm
        self.subtitleLabel = subtitleLabel
        
        super.init(frame: .zero)
        
        setupContent()
        
        titleLabel.adyen.apply(style.title)
    }
    
    @available(*, unavailable)
    internal required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Updating Interface

private extension EmptyStateView {
    
    func setupContent() {
        let contentStack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                subtitleLabel
            ].compactMap { $0 }
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
}
