//
// Copyright (c) 2018 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Displays a list item.
package final class ListItemView: UIView, AnyFormItemView {

    private enum Layout {
        static let checkmarkSize = CGSize(width: 24, height: 24)
        static let checkmarkLeadingSpacing: CGFloat = 20
    }

    private let imageLoader: ImageLoading
    private var imageLoadingTask: AdyenCancellable? {
        willSet { imageLoadingTask?.cancel() }
    }
    
    public var childItemViews: [AnyFormItemView] = []

    /// The theme to use for styling.
    ///
    /// Settable rather than init-only because `ListCell` is dequeued before its theme is known.
    package var theme: CheckoutTheme {
        didSet { applyTheme() }
    }
    
    /// Initializes the list item view.
    package init(
        theme: CheckoutTheme = .default,
        imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()
    ) {
        self.theme = theme
        self.imageLoader = imageLoader
        
        super.init(frame: .zero)
        
        addSubview(contentStackView)
        
        preservesSuperviewLayoutMargins = true
        configureConstraints()
        applyTheme()
    }

    private func applyTheme() {
        let labels = theme.elements.labels

        titleLabel.apply(titleLabelStyle)
        subtitleLabel.apply(labels.footnote.color(theme.colors.textSecondary))
        (trailingView as? UILabel)?.apply(labels.body)

        checkmarkImageView.tintColor = theme.colors.text
        updateImageView()
    }

    private var titleLabelStyle: AdyenLabelStyle {
        let body = theme.elements.labels.body

        switch item?.titleEmphasis {
        case .highlighted:
            return body.color(theme.colors.highlight)
        case .standard, nil:
            return body
        }
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - Item
    
    /// The item displayed in the item view.
    public var item: ListItem? {
        didSet {
            updateItemData(item: item)
            applyTheme()
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
        checkmarkImageView.isHidden = item?.isSelected != true
        updateCheckmarkSpacing()
        
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
        
        trailingView.setContentHuggingPriority(.required, for: .horizontal)
        contentStackView.insertArrangedSubview(trailingView, at: contentStackView.arrangedSubviews.count - 1)
    }

    private func updateCheckmarkSpacing() {
        let checkmarkFollowsTitle = trailingView.isHidden && !checkmarkImageView.isHidden

        contentStackView.setCustomSpacing(
            checkmarkFollowsTitle
                ? Layout.checkmarkLeadingSpacing
                : AdyenUIConstants.stackViewSpacing,
            after: titleSubtitleStackView
        )
        contentStackView.setCustomSpacing(Layout.checkmarkLeadingSpacing, after: trailingView)
    }
    
    private func updateImageView() {
        imageView.contentMode = .scaleAspectFit
        
        guard item?.icon?.canBeModified == true else {
            return imageView.layer.borderWidth = 0
        }

        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0 / UIScreen.main.nativeScale
        imageView.layer.borderColor = theme.colors.separator.cgColor
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

        imageView.adyen.round(using: .fixed(AdyenUIConstants.imageCornerRadius))
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

    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: .adyenCheckmark)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false
        imageView.isHidden = true
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: "checkmark"
        )

        return imageView
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
        let stackView = UIStackView(
            arrangedSubviews: [
                imageView,
                titleSubtitleStackView,
                trailingView,
                checkmarkImageView
            ]
        )
        stackView.setCustomSpacing(16, after: imageView)
        stackView.spacing = AdyenUIConstants.stackViewSpacing
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

            checkmarkImageView.widthAnchor.constraint(equalToConstant: Layout.checkmarkSize.width),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: Layout.checkmarkSize.height),
            
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ]

        checkmarkImageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Trait Collection
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        imageView.layer.borderColor = theme.colors.separator.cgColor
    }
    
}
