//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Displays a list item.
/// :nodoc:
public final class ListItemView: UIView, AnyFormItemView {
    
    /// :nodoc:
    public weak var delegate: FormItemViewDelegate?
    
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
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Item
    
    /// The item displayed in the item view.
    public var item: ListItem? {
        didSet {
            updateItemView()
        }
    }
    
    private func updateItemView() {
        updateTitleLabel()
        updateSubtitleLabel()
        updateImageView()
        backgroundColor = item?.style.backgroundColor
        accessibilityIdentifier = item?.identifier
    }
    
    private func updateTitleLabel() {
        titleLabel.text = item?.title
        
        titleLabel.font = item?.style.title.font ?? .systemFont(ofSize: 17.0)
        titleLabel.textColor = item?.style.title.color ?? UIColor.AdyenCore.componentLabel
        titleLabel.backgroundColor = item?.style.title.backgroundColor
        titleLabel.textAlignment = item?.style.title.textAlignment ?? .natural
        titleLabel.accessibilityIdentifier = item?.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel") }
    }
    
    private func updateSubtitleLabel() {
        subtitleLabel.text = item?.subtitle
        subtitleLabel.isHidden = item?.subtitle?.isEmpty ?? true
        
        subtitleLabel.font = item?.style.subtitle.font ?? .systemFont(ofSize: 14.0)
        subtitleLabel.textColor = item?.style.subtitle.color ?? UIColor.AdyenCore.componentSecondaryLabel
        subtitleLabel.backgroundColor = item?.style.subtitle.backgroundColor
        subtitleLabel.textAlignment = item?.style.subtitle.textAlignment ?? .natural
        subtitleLabel.accessibilityIdentifier = item?.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "subtitleLabel")
        }
    }
    
    private func updateImageView() {
        imageView.imageURL = item?.imageURL
        imageView.contentMode = item?.style.image.contentMode ?? .scaleAspectFit
        imageView.clipsToBounds = item?.style.image.clipsToBounds ?? true
        imageView.layer.cornerRadius = item?.style.image.cornerRadius ?? 4.0
        imageView.layer.borderWidth = item?.style.image.borderWidth ?? 1.0 / UIScreen.main.nativeScale
        imageView.layer.borderColor = item?.style.image.borderColor?.cgColor ?? UIColor.AdyenCore.componentSeparator.cgColor
    }
    
    // MARK: - Image View
    
    private lazy var imageView: NetworkImageView = {
        let imageView = NetworkImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.preservesSuperviewLayoutMargins = true
        
        return imageView
    }()
    
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
    
    private func configureConstraints() {
        let constraints = [
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 40.0),
            imageView.heightAnchor.constraint(equalToConstant: 26.0),
            
            textStackView.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            textStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16.0),
            textStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            textStackView.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Trait Collection
    
    /// :nodoc:
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        imageView.layer.borderColor = item?.style.image.borderColor?.cgColor ?? UIColor.AdyenCore.componentSeparator.cgColor
    }
    
}
