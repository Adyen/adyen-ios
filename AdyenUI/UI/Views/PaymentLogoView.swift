//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Displays a payment method logo clipped to a rounded rect with the Figma `Shadow low` elevation.
///
/// The shadow lives on sibling layers so it is not cut off by the image view's clipping.
/// Styling is driven entirely through this view, keeping the logo treatment in a single place.
package final class PaymentLogoView: UIView {

    /// Figma `Shadow low` elevation for payment method logos.
    private enum Shadow {
        static let nearOpacity: CGFloat = 0.02
        static let nearRadius: CGFloat = 2
        static let nearOffset: CGFloat = 1

        static let farOpacity: CGFloat = 0.04
        static let farRadius: CGFloat = 4
        static let farOffset: CGFloat = 2
    }

    // MARK: - UI Elements

    /// The clipped image view displaying the logo.
    package let imageView: UIImageView

    private let nearShadowLayer = CALayer()
    private let farShadowLayer = CALayer()

    // MARK: - Properties

    /// The image loader used to fetch logos. Reassignable for reused cells.
    package var imageLoader: ImageLoading

    private var imageLoadingTask: AdyenCancellable? {
        willSet { imageLoadingTask?.cancel() }
    }

    private var currentURL: URL?

    /// The fixed size the view is laid out at.
    package let logoSize: CGSize

    /// The corner radius applied to the logo and its shadow. `0` disables rounding.
    package var cornerRadius: CGFloat {
        didSet { applyCornerRadius() }
    }

    /// The (dynamic) shadow color. `nil` disables the shadow. Re-resolved on trait collection changes.
    package var shadowColor: UIColor? {
        didSet { updateShadowColors() }
    }

    /// The fill shown while no image is loaded. `nil` keeps the view transparent.
    package var placeholderColor: UIColor? {
        didSet { updatePlaceholder() }
    }

    // MARK: - Initializers

    package init(
        size: CGSize,
        cornerRadius: CGFloat = AdyenUIConstants.imageCornerRadius,
        imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()
    ) {
        self.logoSize = size
        self.cornerRadius = cornerRadius
        self.imageLoader = imageLoader
        self.imageView = UIImageView()

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        addSubview(imageView)
        imageView.adyen.anchor(inside: self)

        layer.insertSublayer(farShadowLayer, at: 0)
        layer.insertSublayer(nearShadowLayer, at: 0)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])

        nearShadowLayer.shadowOffset = CGSize(width: 0, height: Shadow.nearOffset)
        nearShadowLayer.shadowRadius = Shadow.nearRadius
        nearShadowLayer.shadowOpacity = 1
        farShadowLayer.shadowOffset = CGSize(width: 0, height: Shadow.farOffset)
        farShadowLayer.shadowRadius = Shadow.farRadius
        farShadowLayer.shadowOpacity = 1

        applyCornerRadius()
        updateShadowColors()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    /// Loads and displays the logo at the given URL. `nil` clears the image.
    package func load(url: URL?) {
        guard let url else {
            imageLoadingTask = nil
            currentURL = nil
            setImage(nil)
            return
        }

        guard url != currentURL else { return }
        currentURL = url

        imageLoadingTask = imageLoader.load(url: url) { [weak self] image in
            self?.setImage(image)
        }
    }

    /// Sets the logo image directly. A `nil` image shows the `placeholderColor` if set.
    package func setImage(_ image: UIImage?) {
        imageView.image = image
        imageView.backgroundColor = image == nil ? placeholderColor : nil
    }

    override package var intrinsicContentSize: CGSize {
        logoSize
    }

    // MARK: - Layout

    override package func layoutSubviews() {
        super.layoutSubviews()
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        [nearShadowLayer, farShadowLayer].forEach {
            $0.frame = bounds
            $0.shadowPath = shadowPath
        }
    }

    override package func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateShadowColors()
    }

    // MARK: - Private

    private func applyCornerRadius() {
        imageView.layer.cornerRadius = cornerRadius
        setNeedsLayout()
    }

    private func updatePlaceholder() {
        if imageView.image == nil {
            imageView.backgroundColor = placeholderColor
        }
    }

    private func updateShadowColors() {
        guard let shadowColor else {
            nearShadowLayer.shadowColor = nil
            farShadowLayer.shadowColor = nil
            return
        }

        let resolved = shadowColor.resolvedColor(with: traitCollection)
        nearShadowLayer.shadowColor = resolved.withAlphaComponent(Shadow.nearOpacity).cgColor
        farShadowLayer.shadowColor = resolved.withAlphaComponent(Shadow.farOpacity).cgColor
    }
}
