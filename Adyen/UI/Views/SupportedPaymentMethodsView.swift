//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

internal class SupportedPaymentMethodLogosView: UIView {
    
    internal let imageSize: CGSize
    internal let imageUrls: [URL]
    internal let trailingText: String?
    
    internal var content: UIView? {
        willSet {
            content?.removeFromSuperview()
        }
        didSet {
            guard let content else { return }
            addSubview(content)
            content.adyen.anchor(inside: self)
        }
    }
    
    @AdyenDependency(\.imageLoader) private var imageLoader
    
    internal init(
        imageSize: CGSize = .init(width: 24, height: 16),
        imageUrls: [URL],
        trailingText: String?
    ) {
        self.imageSize = imageSize
        self.imageUrls = imageUrls
        self.trailingText = trailingText
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    override internal func didMoveToWindow() {
        super.didMoveToWindow()
        updateContent()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateContent() {
        guard window != nil else { return }
        
        let imageStyle = ImageStyle(
            borderColor: UIColor.Adyen.componentSeparator,
            borderWidth: 1.0 / UIScreen.main.nativeScale,
            cornerRadius: 3.0,
            clipsToBounds: true,
            contentMode: .scaleAspectFit
        )
        
        let imageViews = imageUrls.map { url in
            let imageView = UIImageView()
            imageView.adyen.apply(imageStyle)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: imageSize.width),
                imageView.heightAnchor.constraint(equalToConstant: imageSize.height)
            ])
            imageView.load(url: url, using: imageLoader)
            return imageView
        }
        
        let label = UILabel()
        label.text = trailingText
        label.isHidden = (trailingText ?? "").isEmpty
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = UIColor.Adyen.componentSecondaryLabel
        
        let stackView = UIStackView(arrangedSubviews: imageViews + [label])
        stackView.spacing = 6
        stackView.axis = .horizontal
        content = stackView
    }
}
