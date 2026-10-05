//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import UIKit

internal final class PaymentMethodItemView: UIView {

    /// How far the item content is inset horizontally from the item edges, so that the press
    /// highlight bleeds around it. Section headers use the same inset to line up with the item titles.
    internal static let contentHorizontalInset: CGFloat = 6

    private enum Layout {
        static let itemHeight: CGFloat = 52.0
        static let contentMargins = NSDirectionalEdgeInsets(
            top: 12,
            leading: PaymentMethodItemView.contentHorizontalInset,
            bottom: 12,
            trailing: PaymentMethodItemView.contentHorizontalInset
        )
        static let iconImageSize: CGSize = .init(width: 40, height: 26)
        static let chevronSize: CGSize = .init(width: 16, height: 16)
    }

    private enum Highlight {
        /// A tap is shorter than the time the highlight needs to be noticed,
        /// so it is held on screen for at least this long.
        static let minimumVisibleDuration: TimeInterval = 0.2
        static let fadeOutDuration: TimeInterval = 0.25
    }

    // MARK: - UI Elements

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = AdyenUIConstants.imageCornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()

    /// Wraps the icon so the shadows are not cut off by the image view's clipping.
    private lazy var iconContainerView: LogoShadowContainerView = {
        let view = LogoShadowContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconImageView)
        iconImageView.adyen.anchor(inside: view)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = AdyenLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = AdyenLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()

    private lazy var trailingInfoView: UIView? = {
        guard let trailingInfoData = item.trailingInfoData else { return nil }
        let logosView = SupportedPaymentMethodLogosView(
            imageUrls: trailingInfoData.logoUrls,
            trailingText: trailingInfoData.text,
            style: logosStyle
        )
        logosView.translatesAutoresizingMaskIntoConstraints = false
        return logosView
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = .adyenChevronRight
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private lazy var contentStackView: UIStackView = {
        let subviews = [
            iconContainerView,
            textStackView,
            trailingInfoView,
            chevronImageView
        ].compactMap { $0 }
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()

    private lazy var highlightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()

    // MARK: - Properties

    private var imageLoadingTask: AdyenCancellable? {
        willSet { imageLoadingTask?.cancel() }
    }

    private var item: PaymentMethodItem
    private let imageLoader: ImageLoader

    /// The moment the highlight became visible, used to keep it on screen long enough to be seen.
    private var highlightedAt: TimeInterval?

    // MARK: - Initializers

    internal init(item: PaymentMethodItem, imageLoader: ImageLoader = ImageLoader()) {
        self.item = item
        self.imageLoader = imageLoader
        super.init(frame: .zero)
        setupView()
        configureView()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setupView() {
        directionalLayoutMargins = Layout.contentMargins

        addSubview(highlightView)
        addSubview(contentStackView)

        // The highlight spans the whole item, while its content sits inside the margins.
        highlightView.adyen.anchor(inside: self)
        contentStackView.adyen.anchor(inside: layoutMarginsGuide)

        NSLayoutConstraint.activate([
            iconContainerView.widthAnchor.constraint(equalToConstant: Layout.iconImageSize.width),
            iconContainerView.heightAnchor.constraint(equalToConstant: Layout.iconImageSize.height),

            chevronImageView.widthAnchor.constraint(equalToConstant: Layout.chevronSize.width),
            chevronImageView.heightAnchor.constraint(equalToConstant: Layout.chevronSize.height),

            heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.itemHeight)
        ])

        applyTheme()
    }

    private func configureView() {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        subtitleLabel.isHidden = item.subtitle == nil

        accessibilityLabel = item.accessibilityLabel ?? item.title
        accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: item.title)
        isAccessibilityElement = true
        accessibilityTraits = .button

        loadIcon(from: item.iconURL)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    private func applyTheme() {
        layer.cornerRadius = item.theme.attributes.cornerRadius
        layer.masksToBounds = true

        // Icon shadows
        updateShadowColors()

        // Title Label
        titleLabel.apply(item.theme.elements.labels.bodyEmphasized)

        // Subtitle Label
        subtitleLabel.apply(item.theme.elements.labels.subheadline)
        subtitleLabel.textColor = item.subtitleColor

        // Chevron ImageView
        chevronImageView.tintColor = item.theme.colors.textSecondary

        // Highlight view
        highlightView.backgroundColor = item.theme.colors.disabled
    }

    private var logosStyle: SupportedPaymentMethodLogosView.Style {
        var style = SupportedPaymentMethodLogosView.Style()
        style.images.borderColor = item.theme.colors.separator
        style.trailingText = TextStyle(
            font: item.theme.elements.labels.subheadline.font,
            color: item.theme.colors.textSecondary
        )
        return style
    }

    override internal func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateShadowColors()
    }

    private func updateShadowColors() {
        iconContainerView.shadowColor = item.theme.colors.supportShadow.resolvedColor(with: traitCollection)
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
        guard !highlighted else {
            highlightedAt = CACurrentMediaTime()
            highlightView.layer.removeAllAnimations()
            highlightView.alpha = 1
            return
        }

        // A tap can be shorter than the time the highlight needs to be noticed,
        // so the remainder of the minimum duration is waited out before fading it back out.
        let elapsed = highlightedAt.map { CACurrentMediaTime() - $0 } ?? Highlight.minimumVisibleDuration
        highlightedAt = nil

        UIView.animate(
            withDuration: Highlight.fadeOutDuration,
            delay: max(0, Highlight.minimumVisibleDuration - elapsed),
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) {
            self.highlightView.alpha = 0
        }
    }
}

/// Draws Figma's `Shadow low` elevation behind a logo via two layers.
/// The shadows live on sibling layers so the clipped image inside does not cut them off.
private final class LogoShadowContainerView: UIView {

    private enum Shadow {
        static let nearOpacity: CGFloat = 0.02
        static let nearRadius: CGFloat = 2
        static let nearOffset: CGFloat = 1

        static let farOpacity: CGFloat = 0.04
        static let farRadius: CGFloat = 4
        static let farOffset: CGFloat = 2
    }

    private let nearShadowLayer = CALayer()
    private let farShadowLayer = CALayer()

    internal var shadowColor: UIColor? {
        didSet {
            nearShadowLayer.shadowColor = shadowColor?.withAlphaComponent(Shadow.nearOpacity).cgColor
            farShadowLayer.shadowColor = shadowColor?.withAlphaComponent(Shadow.farOpacity).cgColor
        }
    }

    override internal init(frame: CGRect) {
        super.init(frame: frame)

        nearShadowLayer.shadowOffset = CGSize(width: 0, height: Shadow.nearOffset)
        nearShadowLayer.shadowRadius = Shadow.nearRadius
        nearShadowLayer.shadowOpacity = 1
        farShadowLayer.shadowOffset = CGSize(width: 0, height: Shadow.farOffset)
        farShadowLayer.shadowRadius = Shadow.farRadius
        farShadowLayer.shadowOpacity = 1

        layer.insertSublayer(farShadowLayer, at: 0)
        layer.insertSublayer(nearShadowLayer, at: 0)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()
        let shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: AdyenUIConstants.imageCornerRadius
        ).cgPath
        [nearShadowLayer, farShadowLayer].forEach {
            $0.frame = bounds
            $0.shadowPath = shadowPath
        }
    }
}
