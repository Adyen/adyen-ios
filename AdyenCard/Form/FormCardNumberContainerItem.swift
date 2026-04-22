//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A form item which consists of card number item and the supported card icons below.
internal final class FormCardNumberContainerItem: FormItem, AdyenObserver {
    
    private enum Constants {
        static let brandDescriptionInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    /// The supported card type logos.
    internal let cardTypeLogos: [FormCardLogosItem.CardTypeLogo]
    
    internal var identifier: String?
    
    internal let style: FormTextItemStyle
    
    internal let showsSupportedCardLogos: Bool
    
    private let localizationParameters: LocalizationParameters?
    
    private let scanCardHandler: (() -> Void)?
   
    internal lazy var subitems: [FormItem] = {
        var subItems: [FormItem] = [numberItem, brandDescriptionItem]
        if showsSupportedCardLogos {
            subItems.append(supportedCardLogosItem)
        }
        return subItems
    }()
    
    internal lazy var numberItem: FormCardNumberItem = {
        let item = FormCardNumberItem(
            cardTypeLogos: cardTypeLogos,
            style: style,
            localizationParameters: localizationParameters,
            scanCardHandler: scanCardHandler
        )
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "numberItem")
        return item
    }()
    
    internal lazy var brandDescriptionItem: FormContainerItem = {
        let style = TextStyle(
            font: .preferredFont(forTextStyle: .footnote),
            color: UIColor.Adyen.componentSecondaryLabel,
            textAlignment: .natural
        )
        let item = FormLabelItem(
            text: localizedString(.creditCardDualBrandDescription, localizationParameters),
            style: style
        )
        
        let containerItem = item.padding(Constants.brandDescriptionInsets)
        containerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "brandDescriptionItem")
        containerItem.isHidden.wrappedValue = true
        
        return containerItem
    }()
    
    internal lazy var supportedCardLogosItem: FormCardLogosItem = {
        let item = FormCardLogosItem(cardLogos: cardTypeLogos, style: style)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "supportedCardLogosItem")
        return item
    }()
    
    internal init(
        cardTypeLogos: [FormCardLogosItem.CardTypeLogo],
        showsSupportedCardLogos: Bool = true,
        style: FormTextItemStyle,
        localizationParameters: LocalizationParameters?,
        scanCardHandler: (() -> Void)?
    ) {
        self.cardTypeLogos = cardTypeLogos
        self.showsSupportedCardLogos = showsSupportedCardLogos
        self.localizationParameters = localizationParameters
        self.style = style
        self.scanCardHandler = scanCardHandler
        
        observe(numberItem.$isActive) { [weak self] _ in
            guard let self else { return }
            if self.showsSupportedCardLogos {
                self.supportedCardLogosItem.isHidden.wrappedValue = self.numberItem.isValid()
            }
            self.updateBrandDescriptionVisibility()
        }
    }
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    internal func update(brands: [CardBrand]) {
        numberItem.update(brands: brands)
        
        if showsSupportedCardLogos {
            supportedCardLogosItem.isHidden.wrappedValue = brands.contains(where: \.isSupported)
        }
        updateBrandDescriptionVisibility()
    }
    
    private func updateBrandDescriptionVisibility() {
        let isDualSelectable = numberItem.brandDisplayMode == .dualSelectable
        let shouldShow = isDualSelectable && (numberItem.isActive || numberItem.isValid())
        brandDescriptionItem.isHidden.wrappedValue = !shouldShow
    }
    
    internal func setCardNumber(_ cardNumber: String) {
        numberItem.setCardNumber(cardNumber)
    }
}

/// Form item to display multiple card logos.
internal final class FormCardLogosItem: FormItem {
    
    internal var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    internal var identifier: String?
    
    internal var subitems: [FormItem] = []
    
    internal let style: FormTextItemStyle
    
    internal var cardLogos: [CardTypeLogo]
    
    internal init(cardLogos: [CardTypeLogo], style: FormTextItemStyle) {
        self.style = style
        self.cardLogos = cardLogos
    }
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardLogosItem) -> FormItemView<FormCardLogosItem> {
        FormCardLogosItemView(item: item)
    }
    
    internal func build(with item: FormCardNumberContainerItem) -> FormItemView<FormCardNumberContainerItem> {
        FormVerticalStackItemView(item: item, itemSpacing: 0)
    }
}

extension FormCardLogosItem {
    /// Describes a card type logo shown in the card number form item.
    internal struct CardTypeLogo: Equatable {
        
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
        
    }
}
