//
// Copyright (c) 2024 Adyen N.V.
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
    
    /// The card's BIN value up to 8 digits.
    /// Reported with every entered digit.
    @AdyenObservable("") internal var binValue: String
    
    /// Initial brand set after detection before any user interaction
    @AdyenObservable(nil) internal private(set) var initialBrand: CardBrand?
    
    /// Brand selected in dual branded cards, set after user selection.
    @AdyenObservable(nil) internal private(set) var selectedDualBrand: CardBrand?
    
    /// Detected brand logo(s) for the entered bin.
    @AdyenObservable([]) internal private(set) var detectedBrandLogos: [FormCardLogosItem.CardTypeLogo]
    
    /// Determines whether the item is currently the focused one (first responder).
    @AdyenObservable(false) internal var isActive
    
    /// Current detected brands, mainly used for dual-branded cards.
    internal private(set) var detectedBrands: [CardBrand] = []
    
    private let localizationParameters: LocalizationParameters?
    
    /// Returns the initial brand for single brand cases
    /// or `selectedDualBrand` for dual brand cases
    internal var currentBrand: CardBrand? {
        isDualBranded ? selectedDualBrand : initialBrand
    }
    
    internal var isDualBranded: Bool = false
    
    /// Initializes the form card number item.
    internal init(
        cardTypeLogos: [FormCardLogosItem.CardTypeLogo],
        style: FormTextItemStyle = FormTextItemStyle(),
        localizationParameters: LocalizationParameters? = nil
    ) {
        // these 4 US debit brands are not to be displayed
        // but should be supported so it's done here for now
        self.cardTypeLogos = cardTypeLogos.filter { logo in
            logo.type != .accel &&
                logo.type != .pulse &&
                logo.type != .star &&
                logo.type != .nyce
        }
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
        cardNumberFormatter.cardType = supportedCardTypes.adyen.type(forCardNumber: value)
        updateBINIfNeeded()
    }
    
    private func updateBINIfNeeded() {
        switch (value, isValid()) {
        case (_, true) where value.count >= Constants.minimumPANLength:
            binValue = String(value.prefix(Constants.largeBinLength))
        default:
            binValue = String(value.prefix(Constants.smallBinLength))
        }
    }
    
    // MARK: - BuildableFormItem
    
    override internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    @discardableResult
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard
            let text = textField.text,
            let textRange = Range(range, in: text),
            let selectedTextRange = textField.selectedTextRange
        else { return true }
        
        let editingDirection = string.count - range.length
        
        let replacementLength: Int = replacementStringLength(
            range: range,
            replacementString: string,
            in: text,
            editingDirection: editingDirection
        )
        
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        
        let sanitizedText = formatter?.sanitizedValue(for: updatedText) ?? updatedText
        let formattedText = formatter?.formattedValue(for: sanitizedText) ?? sanitizedText
        
        let oldCursorOffset = textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.end)
        
        let isAdding = formattedText.count > text.count
        
        let oldNumberOfSpacesBeforeCursor = text.numberOfSpaces(beforeOffset: oldCursorOffset)
        
        let newNumberOfSpacesBeforeCursor = formattedText.numberOfSpaces(
            beforeOffset: oldCursorOffset + replacementLength + (isAdding ? 1 : 0)
        )
        
        let spaceDifference = newNumberOfSpacesBeforeCursor - oldNumberOfSpacesBeforeCursor
        let newCursorOffset = oldCursorOffset + replacementLength + spaceDifference
        
        textField.text = formattedText
        
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorOffset) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        
        return false
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
        updateBINIfNeeded()
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
        
        validator = CardNumberValidator(
            isLuhnCheckEnabled: brand?.isLuhnCheckEnabled ?? true,
            isEnteredBrandSupported: isBrandSupported,
            panLength: brand?.panLength
        )
    }
    
    /// Calculates the length of the string being replaced
    ///
    /// e.g. if the range is `2` characters long and the replacementString is `1` character the replacementStringLength would be `-1`
    private func replacementStringLength(
        range: NSRange,
        replacementString: String,
        in text: String,
        editingDirection: Int
    ) -> Int {
        // Special case to allow "deleting" a space
        // (can only be triggered when the user manually moves the cursor)
        //
        // 1234 5678 |310 // Deleting a character
        if range.length == 1, replacementString.isEmpty, editingDirection == -1 {
            return -1
        }
        
        var length = (formatter?.sanitizedValue(for: replacementString).count) ?? 0
        
        if let rangeIndexes = Range(range, in: text) {
            let replacedText = String(text[rangeIndexes])
            length -= (formatter?.sanitizedValue(for: replacedText).count) ?? 0
        } else {
            length -= range.length
        }
        
        return length
    }
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardNumberItem) -> FormItemView<FormCardNumberItem> {
        FormCardNumberItemView(item: item)
    }
}

private extension String {
    func numberOfSpaces(beforeOffset offset: Int) -> Int {
        max(0, prefix(max(0, offset)).split(separator: " ").count - 1)
    }
}
