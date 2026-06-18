//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import UIKit

/// A form item which consists of card number item and the supported card icons below.
internal final class FormCardNumberContainerItem: FormItem, AdyenObserver {
    
    internal var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    /// The supported card type logos.
    internal let cardBrandLogos: [FormCardLogosItem.CardBrandLogo]
    
    internal var identifier: String?
    
    internal let style: FormTextItemStyle
    
    internal let showSupportedCardBrandLogos: Bool
    
    private let localizationParameters: LocalizationParameters?
    
    private let scanCardHandler: (() -> Void)?
   
    internal lazy var subitems: [FormItem] = {
        var subItems: [FormItem] = [numberItem]
        if showSupportedCardBrandLogos {
            subItems.append(supportedCardLogosItem)
        }
        return subItems
    }()
    
    internal lazy var numberItem: FormCardNumberItem = {
        let item = FormCardNumberItem(
            cardBrandLogos: cardBrandLogos,
            style: style,
            localizationParameters: localizationParameters,
            scanCardHandler: scanCardHandler
        )
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "numberItem")
        return item
    }()
    
    internal lazy var supportedCardLogosItem: FormCardLogosItem = {
        let item = FormCardLogosItem(cardLogos: cardBrandLogos, style: style)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "supportedCardLogosItem")
        return item
    }()
    
    internal init(
        cardBrandLogos: [FormCardLogosItem.CardBrandLogo],
        showSupportedCardBrandLogos: Bool = true,
        style: FormTextItemStyle,
        localizationParameters: LocalizationParameters?,
        scanCardHandler: (() -> Void)?
    ) {
        self.cardBrandLogos = cardBrandLogos
        self.showSupportedCardBrandLogos = showSupportedCardBrandLogos
        self.localizationParameters = localizationParameters
        self.style = style
        self.scanCardHandler = scanCardHandler
        
        if showSupportedCardBrandLogos {
            observe(numberItem.$isActive) { [weak self] _ in
                self?.updateLogosVisibility()
            }
            observe(numberItem.$validationState) { [weak self] state in
                self?.updateLogosVisibility(state: state)
            }
        }
    }
    
    private func updateLogosVisibility() {
        updateLogosVisibility(state: numberItem.validationState)
    }
    
    private func updateLogosVisibility(state: ValidationState) {
        guard showSupportedCardBrandLogos else { return }
        let brandDetected = !numberItem.detectedBrands.isEmpty
        let errorShown = state.shouldShowError
        supportedCardLogosItem.isHidden.wrappedValue =
            brandDetected || numberItem.isValid() || errorShown
    }
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    internal func update(brands: [DetectedCardBrand]) {
        numberItem.update(brands: brands)
        
        updateLogosVisibility()
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
    
    internal var cardLogos: [CardBrandLogo]
    
    internal init(cardLogos: [CardBrandLogo], style: FormTextItemStyle) {
        self.style = style
        self.cardLogos = cardLogos
    }
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardLogosItem) -> FormItemView<FormCardLogosItem> {
        FormCardLogosItemView(item: item, theme: theme)
    }
    
    internal func build(with item: FormCardNumberContainerItem) -> FormItemView<FormCardNumberContainerItem> {
        FormVerticalStackItemView(item: item, itemSpacing: 0, theme: theme)
    }
}

extension FormCardLogosItem {
    /// Describes a card type logo shown in the card number form item.
    internal struct CardBrandLogo: Equatable {
        
        internal let brand: CardBrand
        
        /// The URL of the card type logo.
        internal let url: URL
        
        /// Initializes the card type logo.
        ///
        /// - Parameter cardBrand: The card brand for which to initialize the logo.
        internal init(url: URL, brand: CardBrand) {
            self.url = url
            self.brand = brand
        }
        
    }
}
