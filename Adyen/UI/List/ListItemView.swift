//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Displays a list item.
@_spi(AdyenInternal)
public final class ListItemView: UIView, AnyFormItemView {
    private let imageLoader: ImageLoading
    private var imageLoadingTask: AdyenCancellable? {
        willSet { imageLoadingTask?.cancel() }
    }
    
    public var childItemViews: [AnyFormItemView] = []
    
    /// Initializes the list item view.
    public init(imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()) {
        self.imageLoader = imageLoader
        
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
                
                if let trailingTextLabel = trailingView as? UILabel {
                    trailingTextLabel.adyen.apply(style.trailingText)
                }
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

        updateTrailingView(for: item)
        
        imageView.isHidden = item?.icon == nil
        updateIcon()
    }
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        updateIcon()
    }
    
    private func updateIcon() {
        if let iconUrl = item?.icon?.url, window != nil {
            imageLoadingTask = imageView.load(url: iconUrl, using: imageLoader)
        } else {
            imageLoadingTask = nil
        }
    }
    
    private func updateTrailingView(for item: ListItem?) {
        contentStackView.removeArrangedSubview(trailingView)
        trailingView.removeFromSuperview()
        
        switch item?.trailingInfo {
        case let .text(string):
            let trailingTextLabel = UILabel()
            trailingTextLabel.translatesAutoresizingMaskIntoConstraints = false
            trailingTextLabel.text = string
            trailingTextLabel.accessibilityIdentifier = item?.identifier.map {
                ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "trailingTextLabel")
            }
            trailingView = trailingTextLabel
            trailingView.isHidden = string.isEmpty
        case let .logos(urls, trailingText):
            let trailingLogosView = SupportedPaymentMethodLogosView(
                imageUrls: urls,
                trailingText: trailingText
            )
            trailingLogosView.accessibilityIdentifier = item?.identifier.map {
                ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "trailingLogosView")
            }
            trailingView = trailingLogosView
        case nil:
            trailingView = UIView()
            trailingView.isHidden = true
        }
        
        contentStackView.addArrangedSubview(trailingView)
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
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
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

    private var trailingView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
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
        let stackView = UIStackView(arrangedSubviews: [imageView, titleSubtitleStackView, trailingView])
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

        trailingView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Trait Collection
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        imageView.layer.borderColor = item?.style.image.borderColor?.cgColor ?? UIColor.Adyen.componentSeparator.cgColor
    }
    
}
