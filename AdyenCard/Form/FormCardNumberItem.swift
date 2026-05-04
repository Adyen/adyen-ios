//
// Copyright (c) 2019 Adyen N.V.
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
    
    /// The active brand — set from BIN detection or user selection in dual-brand mode.
    @AdyenObservable(nil) internal private(set) var selectedBrand: CardBrand?
    
    /// Detected brand logo(s) for the entered bin.
    @AdyenObservable([]) internal private(set) var detectedBrandLogos: [FormCardLogosItem.CardTypeLogo]
    
    /// Determines whether the item is currently the focused one (first responder).
    @AdyenObservable(false) internal var isActive
    
    /// Current detected brands, mainly used for dual-branded cards.
    internal private(set) var detectedBrands: [CardBrand] = []
    
    private let localizationParameters: LocalizationParameters?
    
    internal let scanCardHandler: (() -> Void)?
    internal var scanYourCardButtonTitle: String
    
    internal var supportsCardScanning: Bool {
        scanCardHandler != nil
    }
    
    /// Returns the brand to include in the payment request.
    /// Returns `nil` for locally detected brands and `.dualUnselectable` mode.
    internal var currentBrand: CardBrand? {
        guard !isBrandDetectedLocally else { return nil }
        return brandDisplayMode == .dualUnselectable ? nil : selectedBrand
    }
    
    internal var brandDisplayMode: DualBrandAccessoryView.BrandDisplayMode = .single
    
    @AdyenObservable(.primary) internal var brandSelection: DualBrandAccessoryView.BrandSelection
    
    /// Whether the detected brand came from local (regex) detection rather than a server BIN lookup.
    internal var isBrandDetectedLocally = false
    
    internal var onUserBrandSelection: ((CardBrand) -> Void)?

    /// Initializes the form card number item.
    internal init(
        cardTypeLogos: [FormCardLogosItem.CardTypeLogo],
        style: FormTextItemStyle = FormTextItemStyle(),
        localizationParameters: LocalizationParameters? = nil,
        scanCardHandler: (() -> Void)? = nil
    ) {
        self.cardTypeLogos = cardTypeLogos
        self.supportedCardTypes = cardTypeLogos.map(\.type)
        self.localizationParameters = localizationParameters
        self.scanCardHandler = scanCardHandler
        self.scanYourCardButtonTitle = localizedString(.cardScanYourCardButton, localizationParameters)

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
    
    internal func setCardNumber(_ cardNumber: String) {
        value = cardNumber
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
        
        let isDeletingSingleCharacter = (string.count - range.length) == -1
        
        let replacementLength: Int = replacementStringLength(
            range: range,
            replacementString: string,
            in: text,
            isDeletingSingleCharacter: isDeletingSingleCharacter
        )
        
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        
        let sanitizedText = formatter?.sanitizedValue(for: updatedText) ?? updatedText
        let formattedText = formatter?.formattedValue(for: sanitizedText) ?? sanitizedText
        
        let oldCursorOffset = textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.end)
        
        let isAdding = formattedText.count > text.count
        
        let oldNumberOfSpacesBeforeCursor = text.numberOfSpaces(beforeOffset: oldCursorOffset)

        let projectedNewCursorOffset = oldCursorOffset + replacementLength + (isAdding ? 1 : 0)
        let newNumberOfSpacesBeforeCursor = formattedText.numberOfSpaces(
            beforeOffset: projectedNewCursorOffset
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
    /// Sets the first supported one as `selectedBrand`.
    internal func update(brands: [CardBrand]) {
        detectedBrands = brands
        
        switch (brands.count, brands.first(where: \.isSupported)) {
        case (1, _):
            updateSelectedBrand(brands.first)
        case let (2, .some(firstSupportedBrand)):
            updateSelectedBrand(firstSupportedBrand)
        case (2, nil):
            updateSelectedBrand(nil, defaultSupportedValue: false)
        default:
            updateSelectedBrand(nil)
        }
        
        detectedBrandLogos = brands.filter(\.isSupported)
            .compactMap { brand in
                cardTypeLogos.first { $0.type == brand.type }
            }
    }

    /// Selects a brand from the segmented picker by index.
    internal func selectBrand(from selection: DualBrandAccessoryView.BrandSelection) {
        guard let brand = detectedBrands.adyen[safeIndex: selection.rawValue] else { return }
        updateValidation(for: brand)
        self.brandSelection = selection
        self.selectedBrand = brand
        onUserBrandSelection?(brand)
    }

    /// Updates the current brand from the binlookup response.
    private func updateSelectedBrand(_ brand: CardBrand?, defaultSupportedValue: Bool = true) {
        updateValidation(for: brand, defaultSupportedValue: defaultSupportedValue)
        updateBrandSelection(with: brand)
        self.selectedBrand = brand
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
    
    private func updateBrandSelection(with brand: CardBrand?) {
        // Each guard separate to make it readable
        guard let brand,
              let index = detectedBrands.firstIndex(of: brand),
              let selection = DualBrandAccessoryView.BrandSelection(rawValue: index) else {
            brandSelection = .primary
            return
        }
        
        brandSelection = selection
    }
    
    /// Calculates the length of the string being replaced
    ///
    /// e.g. if the range is `2` characters long and the replacementString is `1` character the replacementStringLength would be `-1`
    private func replacementStringLength(
        range: NSRange,
        replacementString: String,
        in text: String,
        isDeletingSingleCharacter: Bool
    ) -> Int {
        // Special case to allow "deleting" a space
        // (can only be triggered when the user manually moves the cursor)
        //
        // 1234 5678 |310 // Deleting a character
        if range.length == 1, replacementString.isEmpty, isDeletingSingleCharacter {
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
