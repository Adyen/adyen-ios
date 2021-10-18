//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A form item which consists of card number item and the supported card icons below.
internal final class FormCardNumberContainerItem: FormItem, Observer {
    
    /// The supported card type logos.
    internal let cardTypeLogos: [FormCardLogoItem.CardTypeLogo]
    
    internal var identifier: String?
    
    internal let style: FormTextItemStyle
    
    /// :nodoc:
    private let localizationParameters: LocalizationParameters?
   
    internal var subitems: [FormItem] {
        [numberItem, logoItem]
    }
    
    internal lazy var numberItem: FormCardNumberItem = {
        let item = FormCardNumberItem(cardTypeLogos: cardTypeLogos,
                                      style: FormTextItemStyle(),
                                      localizationParameters: localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "numberItem")
        return item
    }()
    
    internal lazy var logoItem: FormCardLogoItem = {
        let item = FormCardLogoItem(cardLogos: cardTypeLogos, style: style)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardLogoItem")
        return item
    }()
    
    internal init(cardTypeLogos: [FormCardLogoItem.CardTypeLogo],
                  style: FormTextItemStyle,
                  localizationParameters: LocalizationParameters?) {
        self.cardTypeLogos = cardTypeLogos
        self.localizationParameters = localizationParameters
        self.style = style
        
        observe(numberItem.$isActive) { [weak self] newValue in
            guard let self = self else { return }
            // logo item only visible when number item is active or when it's invalid
            let hidden = !newValue && self.numberItem.isValid()
            self.logoItem.isHidden.wrappedValue = hidden
        }
    }
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

internal final class FormCardLogoItem: FormItem, Hidable {
    
    internal var isHidden: Observable<Bool> = Observable(false)
    
    internal var identifier: String?
    
    internal var subitems: [FormItem] = []
    
    internal let cardLogos: [CardTypeLogo]
    
    internal let style: FormTextItemStyle
    
    internal init(cardLogos: [CardTypeLogo], style: FormTextItemStyle) {
        self.cardLogos = cardLogos
        self.style = style
    }
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardLogoItem) -> FormItemView<FormCardLogoItem> {
        FormCardLogoItemView(item: item)
    }
    
    internal func build(with item: FormCardNumberContainerItem) -> FormItemView<FormCardNumberContainerItem> {
        FormVerticalStackItemView<FormCardNumberContainerItem>(item: item, itemSpacing: 0)
    }
}

extension FormCardLogoItem {
    /// Describes a card type logo shown in the card number form item.
    internal final class CardTypeLogo: Equatable {
        
        internal let type: CardType
        
        /// The URL of the card type logo.
        internal let url: URL
        
        /// Initializes the card type logo.
        ///
        /// - Parameter cardType: The card type for which to initialize the logo.
        internal init(url: URL, type: CardType) {
            self.url = url
            self.type = type
        }
        
        internal static func == (lhs: FormCardLogoItem.CardTypeLogo, rhs: FormCardLogoItem.CardTypeLogo) -> Bool {
            lhs.url == rhs.url && lhs.type == rhs.type
        }
    }
}
