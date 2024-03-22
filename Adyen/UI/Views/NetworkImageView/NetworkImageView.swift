//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// An image view that displays images from a remote location.
@_spi(AdyenInternal)
open class NetworkImageView: UIImageView {
    
    @AdyenDependency(\.networkImageProviderType) private var networkImageProviderType
    private lazy var networkImageProvider = networkImageProviderType.init()
    
    /// The URL of the image to display.
    public var imageURL: URL? {
        didSet {
            image = placeholderImage
            
            // Only load an image when we're in a window.
            if let imageURL, window != nil {
                loadImage(from: imageURL)
            }
        }
    }
    
    /// The image to display before image loading starts and also in case it fails.
    public var placeholderImage: UIImage?
    
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        
        // If we have an image URL and are embedded in a window, load the image if we aren't already.
        if let imageURL, window != nil {
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - Private
    
    private func setImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.image = image
        }
    }

    private func loadImage(from url: URL, ignoreCurrentRequest: Bool = false) {
        networkImageProvider.loadImage(from: url) { [weak self] image in
            guard let self, let image else { return }
            setImage(image)
        }
    }
}
