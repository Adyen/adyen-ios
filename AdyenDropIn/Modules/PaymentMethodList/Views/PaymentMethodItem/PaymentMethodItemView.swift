//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenUI
import UIKit

internal final class PaymentMethodItemView: UIView {

    private enum Layout {
        static let itemHeight: CGFloat = 52.0
        static let sideMargin: CGFloat = 12.0
        static let iconImageHeight: CGFloat = 26.0
        static let iconImageWidth: CGFloat = 40.0
        static let chevronHeight: CGFloat = 14
        static let chevronWidth: CGFloat = 20
    }

    private enum Images {
        static let chevron = "chevron.forward"
    }

    // MARK: - UI Elements
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = AdyenUIConstants.imageCornerRadius
        imageView.layer.borderWidth = 1.0 / UIScreen.main.nativeScale
        imageView.layer.borderColor = item.theme.colors.separator.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.apply(item.theme.elements.labels.bodyEmphasized)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.apply(item.theme.elements.labels.subheadline)
        label.textColor = item.theme.colors.textSecondary
        return label
    }()
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    
    private lazy var trailingInfoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: Images.chevron)
        imageView.tintColor = item.theme.colors.textSecondary
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, textStackView, trailingInfoView, chevronImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var highlightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = item.theme.colors.disabled
        view.alpha = 0
        return view
    }()
    
    // MARK: - Properties
    
    private var imageLoadingTask: AdyenCancellable? {
        willSet { imageLoadingTask?.cancel() }
    }

    private var item: PaymentMethodItem
    private let imageLoader: ImageLoader
    
    // MARK: - Initializers
    
    internal init(item: PaymentMethodItem, imageLoader: ImageLoader = ImageLoader()) {
        self.item = item
        self.imageLoader = imageLoader
        super.init(frame: .zero)
        setupView()
        configure()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private

    private func setupView() {
        layer.cornerRadius = item.theme.attributes.cornerRadius
        layer.masksToBounds = true

        addSubview(highlightView)
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            highlightView.topAnchor.constraint(equalTo: topAnchor),
            highlightView.leadingAnchor.constraint(equalTo: leadingAnchor),
            highlightView.trailingAnchor.constraint(equalTo: trailingAnchor),
            highlightView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconImageWidth),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconImageHeight),

            chevronImageView.widthAnchor.constraint(equalToConstant: Layout.chevronWidth),
            chevronImageView.heightAnchor.constraint(equalToConstant: Layout.chevronHeight),

            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.sideMargin),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.sideMargin),

            heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.itemHeight)
        ])
    }

    private func configure() {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        subtitleLabel.isHidden = item.subtitle == nil

        accessibilityLabel = item.accessibilityLabel ?? item.title
        isAccessibilityElement = true
        accessibilityTraits = .button

        loadIcon(from: item.iconURL)
        updateTrailingInfo()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func updateTrailingInfo() {
        trailingInfoView.subviews.forEach { $0.removeFromSuperview() }
        
        switch item.trailingInfo {
        case let .text(string):
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = string
            label.apply(item.theme.elements.labels.footnote)
            label.setContentHuggingPriority(.required, for: .horizontal)
            trailingInfoView.addSubview(label)
            label.adyen.anchor(inside: trailingInfoView)
            trailingInfoView.isHidden = string.isEmpty
            
        case let .logos(urls, trailingText):
            let logosView = SupportedPaymentMethodLogosView(
                imageUrls: urls,
                trailingText: trailingText
            )
            trailingInfoView.addSubview(logosView)
            logosView.adyen.anchor(inside: trailingInfoView)
            trailingInfoView.isHidden = false
            
        case nil:
            trailingInfoView.isHidden = true
        }
    }

    private func loadIcon(from url: URL?) {
        iconImageView.image = nil
        imageLoadingTask = nil
        
        guard let url else { return }
        
        imageLoadingTask = imageLoader.load(url: url) { [weak self] image in
            self?.iconImageView.image = image
        }
    }
    
    @objc private func handleTap() {
        item.selectionHandler?()
    }
    
    // MARK: - Touch Handling
    
    override internal func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        setHighlighted(true)
    }
    
    override internal func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        setHighlighted(false)
    }
    
    override internal func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setHighlighted(false)
    }
    
    private func setHighlighted(_ highlighted: Bool) {
        UIView.animate(withDuration: highlighted ? 0.05 : 0.3) {
            self.highlightView.alpha = highlighted ? 1 : 0
        }
    }
}
