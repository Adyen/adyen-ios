//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A form item into which a card number is entered.
internal final class FormCardNumberItem: FormTextItem, Observer {
    
    private static let binLength = 12
    
    private let cardNumberFormatter = CardNumberFormatter()
    
    /// The supported card types.
    private let supportedCardTypes: [CardType]
    
    /// Supported card type logos.
    internal let cardTypeLogos: [FormCardLogosItem.CardTypeLogo]
    
    /// The observable of the card's BIN value.
    /// The value contains up to 6 first digits of card' PAN.
    @AdyenObservable("") internal var binValue: String
    
    /// nitial brand set after detection before any user interaction
    @AdyenObservable(nil) internal private(set) var initialBrand: CardBrand?
    
    /// Brand selected in dual branded cards, set after user selection.
    @AdyenObservable(nil) internal private(set) var selectedDualBrand: CardBrand?
    
    /// Detected brand logo(s) for the entered bin.
    @AdyenObservable([]) internal private(set) var detectedBrandLogos: [FormCardLogosItem.CardTypeLogo]
    
    /// Determines whether the item is currently the focused one (first responder).
    @AdyenObservable(false) internal var isActive
    
    /// Current detected brands, mainly used for dual-branded cards.
    internal private(set) var detectedBrands: [CardBrand] = []
    
    /// :nodoc:
    private let localizationParameters: LocalizationParameters?
    
    /// Returns the initial brand for single brand cases
    /// For dual brands returns the brand (`selectedDualBrand`) only after it is selected by the user
    internal var currentBrand: CardBrand? {
        isDualBranded ? selectedDualBrand : initialBrand
    }
    
    /// :nodoc:
    internal var isDualBranded: Bool = false
    
    /// Initializes the form card number item.
    internal init(cardTypeLogos: [FormCardLogosItem.CardTypeLogo],
                  style: FormTextItemStyle = FormTextItemStyle(),
                  localizationParameters: LocalizationParameters? = nil) {
        self.cardTypeLogos = cardTypeLogos
        self.supportedCardTypes = cardTypeLogos.map(\.type)
        
        self.localizationParameters = localizationParameters
        
        super.init(style: style)
        
        observe(publisher) { [weak self] value in self?.valueDidChange(value) }
        
        title = localizedString(.cardNumberItemTitle, localizationParameters)
        validator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: true)
        formatter = cardNumberFormatter
        placeholder = localizedString(.cardNumberItemPlaceholder, localizationParameters)
        validationFailureMessage = localizedString(.cardNumberItemInvalid, localizationParameters)
        keyboardType = .numberPad
    }
    
    // MARK: - Value
    
    private func valueDidChange(_ value: String) {
        binValue = String(value.prefix(FormCardNumberItem.binLength))
        cardNumberFormatter.cardType = supportedCardTypes.adyen.type(forCardNumber: value)
    }
    
    // MARK: - BuildableFormItem
    
    override internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    /// Updates the item with the detected brands.
    /// and sets the first supported one as the `initialBrand`.
    internal func update(brands: [CardBrand]) {
        detectedBrands = brands
        
        switch (brands.count, brands.first(where: \.isSupported)) {
        case (1, _):
            update(initialBrand: brands.first)
        case let (2, .some(firstSupportedBrand)):
            update(initialBrand: firstSupportedBrand)
        case (2, nil):
            // if there are 2 brands and neither is supported,
            // need to show unsupported text
            update(initialBrand: nil, defaultSupportedValue: false)
        default:
            update(initialBrand: nil)
        }
        
        isDualBranded = brands.count == 2 && brands.allSatisfy(\.isSupported)
        
        detectedBrandLogos = brands.filter(\.isSupported)
            .compactMap { brand in
                cardTypeLogos.first { $0.type == brand.type }
            }
    }
    
    /// Changes the selected dual brand with the given index to trigger updates
    /// for the observing objects.
    internal func selectBrand(at index: Int) {
        let newBrand = detectedBrands.adyen[safeIndex: index]
        updateValidation(for: newBrand)
        self.selectedDualBrand = newBrand
    }
    
    /// Updates the initial brand and the related validation checks.
    private func update(initialBrand: CardBrand?, defaultSupportedValue: Bool = true) {
        updateValidation(for: initialBrand, defaultSupportedValue: defaultSupportedValue)
        self.initialBrand = initialBrand
    }
    
    private func updateValidation(for brand: CardBrand?, defaultSupportedValue: Bool = true) {
        // validation message will change based on if brand is supported or not
        // if brand is not supported, allow validation while editing to show the error instantly.
        let isBrandSupported = brand?.isSupported ?? defaultSupportedValue
        if isBrandSupported {
            allowsValidationWhileEditing = false
            validationFailureMessage = localizedString(.cardNumberItemInvalid, localizationParameters)
        } else {
            allowsValidationWhileEditing = true
            validationFailureMessage = localizedString(.cardNumberItemUnknownBrand, localizationParameters)
        }
        
        validator = CardNumberValidator(isLuhnCheckEnabled: brand?.isLuhnCheckEnabled ?? true,
                                        isEnteredBrandSupported: isBrandSupported,
                                        panLength: brand?.panLength)
    }
    
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardNumberItem) -> FormItemView<FormCardNumberItem> {
        FormCardNumberItemView(item: item)
    }
}
