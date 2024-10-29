//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

internal class SupportedPaymentMethodLogosView: UIView {
    
    struct Style: ViewStyle {
        public var backgroundColor: UIColor = .clear
        
        public var images: ImageStyle = .init(
            borderColor: UIColor.Adyen.componentSeparator,
            borderWidth: 1.0 / UIScreen.main.nativeScale,
            cornerRadius: 3.0,
            clipsToBounds: true,
            contentMode: .scaleAspectFit
        )
        
        public var trailingText: TextStyle = .init(
            font: .preferredFont(forTextStyle: .callout),
            color: UIColor.Adyen.componentSecondaryLabel
        )
    }
    
    internal let imageSize: CGSize
    internal let imageUrls: [URL]
    internal let trailingText: String?
    internal let style: Style
    
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
        trailingText: String?,
        style: Style = .init()
    ) {
        self.imageSize = imageSize
        self.imageUrls = imageUrls
        self.trailingText = trailingText
        self.style = style
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    override internal func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview != nil {
            updateContent()
        }
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateContent() {
        backgroundColor = style.backgroundColor
        
        let imageViews = imageUrls.map { url in
            let imageView = UIImageView()
            imageView.adyen.apply(style.images)
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
        label.adyen.apply(style.trailingText)
        
        let stackView = UIStackView(arrangedSubviews: imageViews + [label])
        stackView.spacing = 6
        stackView.axis = .horizontal
        content = stackView
    }
}
