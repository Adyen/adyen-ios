//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Displays a list item.
@_spi(AdyenInternal)
public final class ListItemView: UIView, AnyFormItemView {
    
    public var childItemViews: [AnyFormItemView] = []
    
    /// Initializes the list item view.
    public init() {
        super.init(frame: .zero)
        
        addSubview(contentStackView)
        
        preservesSuperviewLayoutMargins = true
        configureConstraints()
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reset() { /* Do nothing */ }
    
    // MARK: - Item
    
    /// The item displayed in the item view.
    public var item: ListItem? {
        didSet {
            updateItemData(item: item)
            
            if let style = item?.style, oldValue?.style != style {
                updateImageView(style: style)
                titleLabel.adyen.apply(style.title)
                subtitleLabel.adyen.apply(style.subtitle)
                trailingTextLabel.adyen.apply(style.trailingText)
            }
        }
    }
    
    private func updateItemData(item: ListItem?) {
        accessibilityIdentifier = item?.identifier
        
        accessibilityLabel = item?.accessibilityLabel
        isAccessibilityElement = item != nil
        
        titleLabel.text = item?.title
        titleLabel.accessibilityIdentifier = item?.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel") }
        
        subtitleLabel.text = item?.subtitle
        subtitleLabel.isHidden = item?.subtitle?.isEmpty ?? true
        subtitleLabel.accessibilityIdentifier = item?.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "subtitleLabel")
        }

        trailingTextLabel.text = item?.trailingText
        trailingTextLabel.isHidden = item?.trailingText?.isEmpty ?? true
        trailingTextLabel.accessibilityIdentifier = item?.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "trailingTextLabel")
        }
        
        imageView.imageURL = item?.icon?.url
        imageView.isHidden = item?.icon == nil
    }
    
    private func updateImageView(style: ListItemStyle) {
        imageView.contentMode = style.image.contentMode
        
        guard item?.icon?.canBeModified == true else {
            return imageView.layer.borderWidth = 0
        }

        imageView.clipsToBounds = style.image.clipsToBounds
        imageView.layer.borderWidth = style.image.borderWidth
        imageView.layer.borderColor = style.image.borderColor?.cgColor
    }
    
    // MARK: - Image View
    
    private lazy var imageView: NetworkImageView = {
        let imageView = NetworkImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.preservesSuperviewLayoutMargins = true
        
        return imageView
    }()
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        guard item?.icon?.canBeModified == true else {
            return imageView.adyen.round(using: .none)
        }

        imageView.adyen.round(using: item?.style.image.cornerRounding ?? .fixed(8))
    }
    
    // MARK: - Title Label
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        return titleLabel
    }()
    
    // MARK: - Subtitle Label
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.isHidden = true
        
        return subtitleLabel
    }()

    private lazy var trailingTextLabel: UILabel = {
        let trailingTextLabel = UILabel()
        trailingTextLabel.translatesAutoresizingMaskIntoConstraints = false
        trailingTextLabel.isHidden = true
        return trailingTextLabel
    }()
    
    // MARK: - Text Stack View
    
    private lazy var titleSubtitleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleSubtitleStackView, trailingTextLabel])
        stackView.setCustomSpacing(16, after: imageView)
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Layout
    
    private let imageSize = CGSize(width: 40, height: 26)
    
    private func configureConstraints() {
        
        let constraints = [
            contentStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: imageSize.height),
            
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ]

        trailingTextLabel.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Trait Collection
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        imageView.layer.borderColor = item?.style.image.borderColor?.cgColor ?? UIColor.Adyen.componentSeparator.cgColor
    }
    
}
