//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

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
    
    override internal func textFieldDidBeginEditing(_ text: UITextField) {
        super.textFieldDidBeginEditing(text)
        accessory = .customView(cardTypeLogosView)
    }
    
    override internal func textFieldDidEndEditing(_ text: UITextField) {
        super.textFieldDidEndEditing(text)
        if accessory == .valid {
            accessory = .customView(cardTypeLogosView)
        }
    }
    
    // MARK: - Card Type Logos View
    
    internal lazy var cardTypeLogosView: UIView = {
        let cardTypeLogosView = CardsView(logos: item.cardTypeLogos, style: item.style)
        cardTypeLogosView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardTypeLogos")
        cardTypeLogosView.backgroundColor = item.style.backgroundColor
        
        return cardTypeLogosView
    }()
}

// MARK: - FormCardNumberItemView.CardTypeLogoView

extension FormCardNumberItemView {
    
    internal class CardsView: UIStackView, Observer {
        
        private let maxCount: Int
        
        internal init(logos: [FormCardNumberItem.CardTypeLogo], style: FormTextItemStyle, max count: Int = 4) {
            maxCount = count
            super.init(frame: .zero)
            axis = .horizontal
            spacing = FormCardNumberItemView.cardSpacing
            
            for logo in logos {
                let imageView = CardTypeLogoView(cardTypeLogo: logo, style: style.icon)
                imageView.backgroundColor = style.backgroundColor
                self.addArrangedSubview(imageView)

                observe(logo.$isHidden) { [unowned imageView] isHidden in
                    imageView.isHidden = isHidden
                }
            }
        }
        
        @available(*, unavailable)
        internal required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override internal func layoutSubviews() {
            invalidateIntrinsicContentSize()
            super.layoutSubviews()
        }
        
        override internal var intrinsicContentSize: CGSize {
            let cardsCount = CGFloat(arrangedSubviews.filter { !$0.isHidden }.count)
            let width = FormCardNumberItemView.cardSize.width * cardsCount + FormCardNumberItemView.cardSpacing * max(cardsCount - 1, 0)
            return .init(width: max(width, FormCardNumberItemView.cardSpacing), height: FormCardNumberItemView.cardSize.height)
        }
        
    }
    
}

extension FormCardNumberItemView {
    
    private class CardTypeLogoView: NetworkImageView {
        
        private let rounding: CornerRounding
        
        internal init(cardTypeLogo: FormCardNumberItem.CardTypeLogo, style: ImageStyle) {
            self.rounding = style.cornerRounding
            super.init(frame: .zero)
            
            imageURL = cardTypeLogo.url
            
            layer.masksToBounds = style.clipsToBounds
            layer.borderWidth = style.borderWidth
            layer.borderColor = style.borderColor?.cgColor
            backgroundColor = style.backgroundColor
        }
        
        @available(*, unavailable)
        internal required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override internal var intrinsicContentSize: CGSize {
            cardSize
        }
        
        override internal func layoutSubviews() {
            super.layoutSubviews()
            self.adyen.round(using: rounding)
        }
    }
}
