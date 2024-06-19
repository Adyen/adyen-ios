//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view representing a selectableFormItem item.
@_spi(AdyenInternal)
public final class SelectableFormItemView: FormItemView<SelectableFormItem> {
    
    private enum Constants {
        static let upiLogo = "upiLogo"
        static let checkmarkIcon = "verification_true"
    }
    
    private let imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()
    private var imageLoadingTask: AdyenCancellable? {
        willSet { imageLoadingTask?.cancel() }
    }

    // MARK: - ImageView

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(
                named: Constants.upiLogo,
                in: Bundle.coreInternalResources,
                compatibleWith: nil
            )
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    // MARK: - Title Label

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel") }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        return titleLabel
    }()

    // MARK: - Checkmark Imageview

    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(
                named: Constants.checkmarkIcon,
                in: Bundle.coreInternalResources,
                compatibleWith: nil
            )
        )

        let iconSize = CGSize(width: 16.0, height: 16.0)
        imageView.adyen.round(using: item.style.imageStyle.cornerRounding)
        imageView.clipsToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: iconSize.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: iconSize.height).isActive = true
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "checkmark")
        imageView.isHidden = !item.isSelected

        return imageView
    }()

    // MARK: - Content StackView

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, checkmarkImageView])
        stackView.setCustomSpacing(16, after: imageView)
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill

        return stackView
    }()

    // MARK: - Item Button

    private lazy var itemButton: UIButton = {
        let customButton = UIButton(type: .system)
        customButton.addTarget(self, action: #selector(didSelectItemButton), for: .touchUpInside)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.preservesSuperviewLayoutMargins = true
        customButton.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "button")
        }
        customButton.addSubview(contentStackView)
        
        contentStackView.isUserInteractionEnabled = false

        return customButton
    }()

    @objc internal func didSelectItemButton() {
        item.selectionHandler?()
    }

    /// Initializes the selectable form item view.
    public required init(item: SelectableFormItem) {
        super.init(item: item)
        backgroundColor = item.style.backgroundColor

        addSubview(itemButton)

        accessibilityIdentifier = item.identifier
        accessibilityLabel = item.accessibilityLabel
        isAccessibilityElement = true

        updateIcon()
        updateImageView(style: item.style)
        configureConstraints()

        preservesSuperviewLayoutMargins = true

        observe(item.$isSelected) { [weak self] isSelected in
            guard let self else { return }
            self.checkmarkImageView.isHidden = !isSelected
        }
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        updateIcon()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        imageView.adyen.round(using: item.style.imageStyle.cornerRounding)
    }

    private func updateImageView(style: SelectableFormItemStyle) {
        imageView.contentMode = style.imageStyle.contentMode
        imageView.clipsToBounds = style.imageStyle.clipsToBounds
        imageView.layer.borderWidth = style.imageStyle.borderWidth
        imageView.layer.borderColor = style.imageStyle.borderColor?.cgColor
    }

    private func updateIcon() {
        if let iconUrl = item.imageUrl, window != nil {
            imageLoadingTask = imageView.load(url: iconUrl, using: imageLoader)
        } else {
            imageLoadingTask = nil
        }
    }

    // MARK: - Layout

    private func configureConstraints() {
        let iconImageSize = CGSize(width: 40, height: 26)
        
        itemButton.adyen.anchor(inside: self)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
    
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: itemButton.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: itemButton.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: itemButton.layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: itemButton.layoutMarginsGuide.trailingAnchor),

            imageView.widthAnchor.constraint(equalToConstant: iconImageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: iconImageSize.height),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
    }
}
