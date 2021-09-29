//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class FormCardLogoItemView: FormItemView<FormCardLogoItem> {
    
    private enum Constants {
        static let cardSpacing: CGFloat = 4.0
        static let cardSize = CGSize(width: 24.0, height: 16.0)
    }
    
    private lazy var cardsView: CardsView = {
        let stackView = CardsView(logos: item.cardLogos, style: item.style)
        stackView.axis = .horizontal
        stackView.spacing = Constants.cardSpacing
        return stackView
    }()
    
    internal required init(item: FormCardLogoItem) {
        super.init(item: item)
        cardsView.adyen.anchor(inside: self)
    }
    
}

extension FormCardLogoItemView {
    internal class CardsView: UIStackView, Observer {
        
        internal init(logos: [FormCardLogoItem.CardTypeLogo], style: FormTextItemStyle) {
            super.init(frame: .zero)
            axis = .horizontal
            spacing = Constants.cardSpacing
            
            for logo in logos {
                let imageView = CardTypeLogoView(cardTypeLogo: logo, style: style.icon)
                imageView.backgroundColor = style.backgroundColor
                addArrangedSubview(imageView)
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
            let width = Constants.cardSize.width * cardsCount + Constants.cardSpacing * max(cardsCount - 1, 0)
            return .init(width: max(width, Constants.cardSpacing), height: Constants.cardSize.height)
        }
        
    }
}

extension FormCardLogoItemView {
    private class CardTypeLogoView: NetworkImageView {
        
        private let rounding: CornerRounding
        
        internal init(cardTypeLogo: FormCardLogoItem.CardTypeLogo, style: ImageStyle) {
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
            Constants.cardSize
        }
        
        override internal func layoutSubviews() {
            super.layoutSubviews()
            self.adyen.round(using: rounding)
        }
    }
}
