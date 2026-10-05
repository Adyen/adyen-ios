//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import UIKit

package class SupportedPaymentMethodLogosView: UIView {

    package struct Style: ViewStyle {
        package var backgroundColor: UIColor = .clear

        package var images: ImageStyle = .init(
            borderColor: UIColor.Adyen.componentSeparator,
            borderWidth: 1.0 / UIScreen.main.nativeScale,
            cornerRadius: 3.0,
            clipsToBounds: true,
            contentMode: .scaleAspectFit
        )
        
        /// The color of the shadow shown behind each logo. `nil` shows no shadow.
        package var logoShadowColor: UIColor?

        package var trailingText: TextStyle = .init(
            font: .preferredFont(forTextStyle: .callout),
            color: UIColor.Adyen.componentSecondaryLabel
        )
        
        package init() {}
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
    
    package init(
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
    
    override package func willMove(toSuperview newSuperview: UIView?) {
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
        
        let imageViews = imageUrls.map { url -> UIView in
            let logoView = PaymentLogoView(size: imageSize, imageLoader: imageLoader)
            logoView.imageView.adyen.apply(style.images)
            logoView.shadowColor = style.logoShadowColor
            if case let .fixed(radius) = style.images.cornerRounding {
                logoView.cornerRadius = radius
            }
            logoView.load(url: url)
            return logoView
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
