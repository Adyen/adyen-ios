//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension IssuerListEmptyView {
    
    internal struct Style: ViewStyle {
        
        internal var title: TextStyle
        internal var subtitle: TextStyle
        internal var backgroundColor: UIColor
        
        internal init(
            title: TextStyle = .init(
                font: .preferredFont(forTextStyle: .title2).adyen.font(with: .bold),
                color: .Adyen.componentLabel
            ),
            subtitle: TextStyle = .init(
                font: .preferredFont(forTextStyle: .subheadline),
                color: .Adyen.componentSecondaryLabel
            ),
            backgroundColor: UIColor = .clear
        ) {
            self.title = title
            self.subtitle = subtitle
            self.backgroundColor = backgroundColor
        }
    }
}

/// The empty view to be used in the IssuerListComponent SearchViewController
internal class IssuerListEmptyView: UIView, SearchResultsEmptyView {
    
    private let style: Style
    private let localizationParameters: LocalizationParameters?
    
    public var searchTerm: String {
        didSet { updateLabels() }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "search",
                                  in: Bundle.coreInternalResources,
                                  compatibleWith: nil)
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        imageView.setContentHuggingPriority(.required, for: .vertical)

        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        return titleLabel
    }()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        
        return subtitleLabel
    }()
    
    // MARK: - Stack View
    
    internal init(
        style: Style = .init(),
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.style = style
        self.localizationParameters = localizationParameters
        self.searchTerm = ""
        
        super.init(frame: .zero)
        
        let contentStack = UIStackView(
            arrangedSubviews: [
                imageView,
                titleLabel,
                subtitleLabel
            ]
        )
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.distribution = .fill
        addSubview(contentStack)
        
        contentStack.setCustomSpacing(32.0, after: imageView)
        contentStack.setCustomSpacing(4.0, after: titleLabel)
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -16),
            contentStack.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor, constant: 0)
        ])
        
        updateLabels()
    }
    
    @available(*, unavailable)
    internal required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension IssuerListEmptyView {
    
    func updateLabels() {
        titleLabel.text = "\(localizedString(.paybybankTitle, localizationParameters)) '\(searchTerm)'"
        subtitleLabel.text = localizedString(.paybybankSubtitle, localizationParameters)
        
        titleLabel.font = style.title.font
        subtitleLabel.font = style.subtitle.font
        titleLabel.textColor = style.title.color
        subtitleLabel.textColor = style.subtitle.color
    }
}
