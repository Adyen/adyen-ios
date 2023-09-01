//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A form item which consists of card number item and the supported card icons below.
final class FormCardNumberContainerItem: FormItem, AdyenObserver {
    
    /// The supported card type logos.
    let cardTypeLogos: [FormCardLogosItem.CardTypeLogo]
    
    var identifier: String?
    
    let style: FormTextItemStyle
    
    let showsSupportedCardLogos: Bool
    
    private let localizationParameters: LocalizationParameters?
   
    lazy var subitems: [FormItem] = {
        var subItems: [FormItem] = [numberItem]
        if showsSupportedCardLogos {
            subItems.append(supportedCardLogosItem)
        }
        return subItems
    }()
    
    lazy var numberItem: FormCardNumberItem = {
        let item = FormCardNumberItem(cardTypeLogos: cardTypeLogos,
                                      style: style,
                                      localizationParameters: localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "numberItem")
        return item
    }()
    
    lazy var supportedCardLogosItem: FormCardLogosItem = {
        let item = FormCardLogosItem(cardLogos: cardTypeLogos, style: style)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "supportedCardLogosItem")
        return item
    }()
    
    init(cardTypeLogos: [FormCardLogosItem.CardTypeLogo],
         showsSupportedCardLogos: Bool = true,
         style: FormTextItemStyle,
         localizationParameters: LocalizationParameters?) {
        self.cardTypeLogos = cardTypeLogos
        self.showsSupportedCardLogos = showsSupportedCardLogos
        self.localizationParameters = localizationParameters
        self.style = style
        
        if showsSupportedCardLogos {
            observe(numberItem.$isActive) { [weak self] _ in
                guard let self = self else { return }
                // logo item should be visible when field is invalid after active state changes
                self.supportedCardLogosItem.isHidden.wrappedValue = self.numberItem.isValid()
            }
        }
    }
    
    func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    func update(brands: [CardBrand]) {
        numberItem.update(brands: brands)
        
        if showsSupportedCardLogos {
            supportedCardLogosItem.isHidden.wrappedValue = brands.contains(where: \.isSupported)
        }
    }
}

/// Form item to display multiple card logos.
final class FormCardLogosItem: FormItem, Hidable {
    
    var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    var identifier: String?
    
    var subitems: [FormItem] = []
    
    let style: FormTextItemStyle
    
    var cardLogos: [CardTypeLogo]
    
    init(cardLogos: [CardTypeLogo], style: FormTextItemStyle) {
        self.style = style
        self.cardLogos = cardLogos
    }
    
    func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}

extension FormItemViewBuilder {
    func build(with item: FormCardLogosItem) -> FormItemView<FormCardLogosItem> {
        FormCardLogosItemView(item: item)
    }
    
    func build(with item: FormCardNumberContainerItem) -> FormItemView<FormCardNumberContainerItem> {
        FormCardNumberContainerItemView(item: item, itemSpacing: 0)
    }
}

extension FormCardLogosItem {
    /// Describes a card type logo shown in the card number form item.
    struct CardTypeLogo: Equatable {
        
        let type: CardType
        
        /// The URL of the card type logo.
        let url: URL
        
        /// Initializes the card type logo.
        ///
        /// - Parameter cardType: The card type for which to initialize the logo.
        init(url: URL, type: CardType) {
            self.url = url
            self.type = type
        }
        
        static func == (lhs: FormCardLogosItem.CardTypeLogo, rhs: FormCardLogosItem.CardTypeLogo) -> Bool {
            lhs.url == rhs.url && lhs.type == rhs.type
        }
    }
}
