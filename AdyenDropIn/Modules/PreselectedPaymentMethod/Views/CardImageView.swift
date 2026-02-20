//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal class CardImageItem {

    /// Configuration for how the image size should be determined.
    internal enum SizeMode {
        /// Use a fixed size, ignoring the loaded image's actual size.
        case fixed(CGSize)
        /// Use the loaded image's actual size, updating constraints dynamically. You need to provide an initial size.
        case variable(CGSize)

        /// Returns the initial size to use for constraints.
        internal var initialSize: CGSize {
            switch self {
            case let .fixed(size):
                return size
            case let .variable(size):
                return size
            }
        }
    }

    /// The URL of the card image.
    internal var imageURL: URL?

    internal var identifier: String?

    /// The size mode of the card image.
    internal var sizeMode: SizeMode

    /// Initializes the form card image item.
    ///
    /// - Parameters:
    ///   - imageURL: The URL of the card image to display.
    ///   - sizeMode: The size mode of the card image.
    ///   - identifier: An optional accessibility identifier.
    internal init(
        imageURL: URL?,
        sizeMode: SizeMode,
        identifier: String? = nil
    ) {
        self.imageURL = imageURL
        self.sizeMode = sizeMode
        self.identifier = identifier
    }
}

/// A view that displays a card image with shadow styling.
internal final class CardImageView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let topPadding: CGFloat = 40
        static let bottomPadding: CGFloat = 16
        static let shadowOffsetHeight: CGFloat = 2
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.15
        static let cardImageViewCornerRadius: CGFloat = 5
    }

    // MARK: - Properties

    private let imageLoader: ImageLoading
    private var imageLoadingTask: AdyenCancellable? {
        willSet { imageLoadingTask?.cancel() }
    }

    private let item: CardImageItem
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    /// Called when the image has finished loading and constraints have been updated.
    internal var onImageLoaded: (() -> Void)?

    /// Designated initializer: Initializes the form card image item view.
    ///
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - imageLoader: The image loader to use for loading the card image.
    internal init(item: CardImageItem, imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()) {
        self.imageLoader = imageLoader
        self.item = item
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable, message: "Use init(item:imageLoader:) instead.")
    internal required init?(coder: NSCoder) {
        nil
    }

    // MARK: - View Setup

    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(imageView)
        configureConstraints()
        applyShadow()
    }

    private func configureConstraints() {
        widthConstraint = containerView.widthAnchor.constraint(equalToConstant: item.sizeMode.initialSize.width)
        heightConstraint = containerView.heightAnchor.constraint(equalToConstant: item.sizeMode.initialSize.height)
        heightConstraint?.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: Constants.topPadding),
            containerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -Constants.bottomPadding),
            containerView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            widthConstraint!,
            heightConstraint!,

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }

    // MARK: - Shadow

    private func applyShadow() {
        // TODO: Robert: Use AdyenTheme
        containerView.backgroundColor = .systemBackground
        containerView.layer.shadowColor = UIColor.label.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: Constants.shadowOffsetHeight)
        containerView.layer.shadowRadius = Constants.shadowRadius
        containerView.layer.shadowOpacity = Constants.shadowOpacity
        containerView.layer.masksToBounds = false
    }

    // MARK: - Image Loading

    override internal func didMoveToWindow() {
        super.didMoveToWindow()
        updateCardImage()
    }

    private func updateCardImage() {
        if let imageURL = item.imageURL, window != nil {
            imageLoadingTask = imageLoader.load(url: imageURL) { [weak self] image in
                guard let self, let image else { return }
                self.imageView.image = image
                if case .variable = self.item.sizeMode {
                    self.updateConstraints(for: image.size)
                }
                self.onImageLoaded?()
            }
        } else {
            imageLoadingTask = nil
        }
    }

    private func updateConstraints(for imageSize: CGSize) {
        guard imageSize.width > 0, imageSize.height > 0 else { return }
        widthConstraint?.constant = imageSize.width
        heightConstraint?.constant = imageSize.height
        setNeedsLayout()
    }

    // MARK: - Subviews

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.cardImageViewCornerRadius
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
}
