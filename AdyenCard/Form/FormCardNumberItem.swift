//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A form item into which a card number is entered.
internal final class FormCardNumberItem: FormTextItem, AdyenObserver {
    
    private enum Constants {
        static let smallBinLength = 6
        static let largeBinLength = 8
        static let minimumPANLength = 16
    }

    private let cardNumberFormatter = CardNumberFormatter()

    /// The supported card types.
    private let supportedCardTypes: [CardType]
    
    /// Supported card type logos.
    internal let cardTypeLogos: [FormCardLogosItem.CardTypeLogo]
    
    /// The card's PAN value.
    /// Reported with every entered digit.
    @AdyenObservable("") internal var panValue: String
    
    /// The card's BIN value up to 8 digits.
    /// Reported with every entered digit.
    @AdyenObservable("") internal var binValue: String
    
    /// Currently selected brand for the entered bin.
    @AdyenObservable(nil) internal private(set) var currentBrand: CardBrand?
    
    /// Detected brand logo(s) for the entered bin.
    @AdyenObservable([]) internal private(set) var detectedBrandLogos: [FormCardLogosItem.CardTypeLogo]
    
    /// Determines whether the item is currently the focused one (first responder).
    @AdyenObservable(false) internal var isActive
    
    /// Current detected brands, mainly used for dual-branded cards.
    internal private(set) var detectedBrands: [CardBrand] = []
    
    private let localizationParameters: LocalizationParameters?
    
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
        panValue = value
        cardNumberFormatter.cardType = supportedCardTypes.adyen.type(forCardNumber: value)
        updateBINIfNeeded()
    }
    
    private func updateBINIfNeeded() {
        switch (value, isValid()) {
        case (_, true) where value.count > Constants.minimumPANLength:
            binValue = String(value.prefix(Constants.largeBinLength))
        default:
            binValue = String(value.prefix(Constants.smallBinLength))
        }
    }
    
    // MARK: - BuildableFormItem
    
    override internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    /// Updates the item with the detected brands.
    /// and sets the first supported one as the `currentBrand`.
    internal func update(brands: [CardBrand]) {
        detectedBrands = brands
        switch (brands.count, brands.first(where: \.isSupported)) {
        case (1, _):
            update(currentBrand: brands.first)
        case let (2, .some(firstSupportedBrand)):
            update(currentBrand: firstSupportedBrand)
        case (2, nil):
            // if there are 2 brands and neither is supported,
            // need to show unsupported text
            update(currentBrand: nil, defaultSupportedValue: false)
        default:
            update(currentBrand: nil)
        }
        
        detectedBrandLogos = brands.filter(\.isSupported)
            .compactMap { brand in
                cardTypeLogos.first { $0.type == brand.type }
            }
    }
    
    /// Changes current brand with the given index to trigger updates
    /// for the observing objects.
    internal func selectBrand(at index: Int) {
        let newBrand = detectedBrands.adyen[safeIndex: index]
        update(currentBrand: newBrand)
    }
    
    /// Updates the current brand and the related validation checks.
    private func update(currentBrand: CardBrand?, defaultSupportedValue: Bool = true) {
        // validation message will change based on if brand is supported or not
        // if brand is not supported, allow validation while editing to show the error instantly.
        let isBrandSupported = currentBrand?.isSupported ?? defaultSupportedValue
        if isBrandSupported {
            allowsValidationWhileEditing = false
            validationFailureMessage = localizedString(.cardNumberItemInvalid, localizationParameters)
        } else {
            allowsValidationWhileEditing = true
            validationFailureMessage = localizedString(.cardNumberItemUnknownBrand, localizationParameters)
        }
        
        validator = CardNumberValidator(isLuhnCheckEnabled: currentBrand?.isLuhnCheckEnabled ?? true,
                                        isEnteredBrandSupported: isBrandSupported,
                                        panLength: currentBrand?.panLength)
        self.currentBrand = currentBrand
        updateBINIfNeeded()
    }
    
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardNumberItem) -> FormItemView<FormCardNumberItem> {
        FormCardNumberItemView(item: item)
    }
}
