//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Displays a list item.
/// :nodoc:
public final class ListItemView: UIView, AnyFormItemView {
    
    /// :nodoc:
    public var childItemViews: [AnyFormItemView] = []
    
    /// Initializes the list item view.
    public init() {
        super.init(frame: .zero)
        
        addSubview(imageView)
        addSubview(textStackView)
        
        preservesSuperviewLayoutMargins = true
        configureConstraints()
    }
    
    /// :nodoc:
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Item
    
    /// The item displayed in the item view.
    public var item: ListItem? {
        didSet {
            updateItemData(item: item)
            
            if let style = item?.style, oldValue?.style != style {
                updateImageView(style: style)
                titleLabel.adyen.apply(style.title)
                subtitleLabel.adyen.apply(style.subtitle)
            }
        }
    }
    
    private func updateItemData(item: ListItem?) {
        accessibilityIdentifier = item?.identifier
        
        titleLabel.text = item?.title
        titleLabel.accessibilityIdentifier = item?.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel") }
        
        subtitleLabel.text = item?.subtitle
        subtitleLabel.isHidden = item?.subtitle?.isEmpty ?? true
        subtitleLabel.accessibilityIdentifier = item?.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "subtitleLabel")
        }
        
        imageView.imageURL = item?.imageURL
    }
    
    private func updateImageView(style: ListItemStyle) {
        imageView.contentMode = style.image.contentMode
        guard item?.canModifyIcon == true else {
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

        guard item?.canModifyIcon == true else {
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
    
    // MARK: - Text Stack View
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Layout
    
    private let imageSize = CGSize(width: 40, height: 26)
    
    private func configureConstraints() {
        let constraints = [
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: imageSize.height),
            
            textStackView.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            textStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16.0),
            textStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            textStackView.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Trait Collection
    
    /// :nodoc:
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard item?.canModifyIcon == true else {
            return imageView.layer.borderColor = nil
        }

        imageView.layer.borderColor = item?.style.image.borderColor?.cgColor ?? UIColor.Adyen.componentSeparator.cgColor
    }
    
    override public var intrinsicContentSize: CGSize {
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width,
                                height: UIView.layoutFittingCompressedSize.height)
        let size = textStackView.systemLayoutSizeFitting(targetSize,
                                                         withHorizontalFittingPriority: .fittingSizeLevel,
                                                         verticalFittingPriority: .fittingSizeLevel)
        return size + layoutMargins.size + CGSize(width: imageSize.width, height: 0)
    }
    
}
