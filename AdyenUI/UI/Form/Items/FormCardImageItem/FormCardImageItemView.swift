//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A view that displays a card image with shadow styling.
internal final class FormCardImageItemView: FormItemView<FormCardImageItem> {

    private let imageLoader: ImageLoading
    private var imageLoadingTask: AdyenCancellable? {
        willSet { imageLoadingTask?.cancel() }
    }

    /// Initializes the form card image item view.
    ///
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - imageLoader: The image loader to use for loading the card image.
    internal init(item: FormCardImageItem, imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()) {
        self.imageLoader = imageLoader
        super.init(item: item)
        setupView()
    }

    /// Initializes the form card image item view with default image loader.
    ///
    /// - Parameter item: The item represented by the view.
    internal required convenience init(item: FormCardImageItem) {
        self.init(item: item, imageLoader: ImageLoaderProvider.imageLoader())
    }

    // MARK: - View Setup

    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(imageView)
        configureConstraints()
        applyShadow()
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 40),
            containerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -16),
            containerView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: item.size.width),
            containerView.heightAnchor.constraint(equalToConstant: item.size.height),

            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }

    // MARK: - Shadow

    private func applyShadow() {
        containerView.layer.shadowColor = UIColor(red: 0, green: 0.071, blue: 0.133, alpha: 0.04).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 1
        containerView.layer.masksToBounds = false
    }

    // MARK: - Image Loading

    override internal func didMoveToWindow() {
        super.didMoveToWindow()
        updateIcon()
    }

    private func updateIcon() {
        if let imageURL = item.imageURL, window != nil {
            imageLoadingTask = imageView.load(url: imageURL, using: imageLoader)
        } else {
            imageLoadingTask = nil
        }
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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = item.cornerRadius
        imageView.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.973, alpha: 1)
        return imageView
    }()
}
