//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A view representing a form card number item.
internal final class FormCardNumberItemView: FormTextItemView<FormCardNumberItem> {
    
    private static let cardSpacing: CGFloat = 4.0
    private static let cardSize = CGSize(width: 24.0, height: 16.0)
    
    /// Initializes the form card number item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormCardNumberItem) {
        super.init(item: item)
        accessory = .customView(cardTypeLogosView)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func textFieldDidBeginEditing(_ text: UITextField) {
        super.textFieldDidBeginEditing(text)
        accessory = .customView(cardTypeLogosView)
    }
    
    internal override func textFieldDidEndEditing(_ text: UITextField) {
        super.textFieldDidEndEditing(text)
        if accessory == .valid {
            accessory = .customView(cardTypeLogosView)
        }
    }
    
    // MARK: - Card Type Logos View
    
    private lazy var cardTypeLogosView: UIView = {
        let cardTypeLogosView = CardsView(logos: item.cardTypeLogos, style: item.style)
        cardTypeLogosView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardTypeLogos")
        cardTypeLogosView.backgroundColor = item.style.backgroundColor
        
        return cardTypeLogosView
    }()
}

// MARK: - FormCardNumberItemView.CardTypeLogoView

private extension FormCardNumberItemView {
    
    private class CardsView: UIStackView, Observer {
        
        private let maxCount: Int
        private var cardLogos: [CardTypeLogoView] = []
        
        init(logos: [FormCardNumberItem.CardTypeLogo], style: FormTextItemStyle, max count: Int = 4) {
            maxCount = count
            super.init(frame: .zero)
            axis = .horizontal
            spacing = FormCardNumberItemView.cardSpacing
            
            logos.forEach { logo in
                let imageView = CardTypeLogoView(cardTypeLogo: logo, style: style.icon)
                imageView.backgroundColor = style.backgroundColor
                cardLogos.append(imageView)
                
                observe(logo.isHidden) { [unowned imageView, weak self] isHidden in
                    self?.set(view: imageView, hidden: isHidden)
                }
                
                logo.isHidden.publish(false)
            }
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            invalidateIntrinsicContentSize()
            super.layoutSubviews()
        }
        
        override var intrinsicContentSize: CGSize {
            let cardsCount = CGFloat(arrangedSubviews.filter { !$0.isHidden }.count)
            let width = FormCardNumberItemView.cardSize.width * cardsCount + FormCardNumberItemView.cardSpacing * max(cardsCount - 1, 0)
            return .init(width: max(width, FormCardNumberItemView.cardSpacing), height: FormCardNumberItemView.cardSize.height)
        }
        
        private func set(view: UIView, hidden: Bool) {
            if hidden {
                view.removeFromSuperview()
            } else if arrangedSubviews.count < maxCount {
                addArrangedSubview(view)
            }
        }
        
    }
    
}

private extension FormCardNumberItemView {
    
    private class CardTypeLogoView: NetworkImageView {
        
        internal init(cardTypeLogo: FormCardNumberItem.CardTypeLogo, style: ImageStyle) {
            super.init(frame: .zero)
            
            imageURL = cardTypeLogo.url
            
            layer.masksToBounds = style.clipsToBounds
            layer.cornerRadius = style.cornerRadius
            layer.borderWidth = style.borderWidth
            layer.borderColor = style.borderColor?.cgColor
            backgroundColor = style.backgroundColor
        }
        
        internal required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        internal override var intrinsicContentSize: CGSize {
            return cardSize
        }
        
    }
    
}
