//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a phone number entry form item.
@_spi(AdyenInternal)
public final class FormPhoneNumberItem: FormTextItem {
    
    /// The phone prefix picker item.
    internal let phonePrefixItem: FormPhoneExtensionPickerItem
    
    /// The phone prefix value.
    public var prefix: String {
        phonePrefixItem.value?.value ?? ""
    }
    
    public var phoneNumber: String {
        prefix + value
    }
    
    /// Initializes the phone number item.
    ///
    /// - Parameter selectableValues: The list of values to select from.
    /// - Parameter style: The `FormTextItemStyle` UI style.
    /// - Parameter localizationParameters: Parameters for custom localization, leave it nil to use the default parameters.
    public init(
        phoneNumber: PhoneNumber?,
        selectableValues: [PhoneExtension],
        style: FormTextItemStyle,
        localizationParameters: LocalizationParameters? = nil,
        presenter: WeakReferenceViewControllerPresenter
    ) {
        phonePrefixItem = .init(
            preselectedExtension: selectableValues.preselectedPhoneNumberPrefix(for: phoneNumber),
            selectableExtensions: selectableValues,
            validationFailureMessage: nil,
            style: style,
            presenter: presenter
        )
        
        super.init(style: style)
        
        phonePrefixItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneExtensionPickerItem")
        value = phoneNumber?.value ?? ""

        title = localizedString(.phoneNumberTitle, localizationParameters)
        placeholder = localizedString(.phoneNumberPlaceholder, localizationParameters)
        formatter = NumericFormatter()
        validator = NumericStringValidator(minimumLength: 1, maximumLength: 15)
        validationFailureMessage = localizedString(.phoneNumberInvalid, localizationParameters)
        keyboardType = .numberPad
    }
    
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    @discardableResult
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard
            let text = textField.text,
            let textRange = Range(range, in: text),
            let selectedTextRange = textField.selectedTextRange
        else { return true }
        
        /// 1234 56|31 0
        /// 1234 567|3 10 // Adding 7 -> move 1 to the right
        /// 1234 5678 |310 // Adding 8 -> move 2 to the right
        /// 1234 5678 9|310 // Adding 9 -> move 1 to the right
        /// 1234 5678| 310 // Removing 9 -> move 2 to the left
        /// 1234 567|3 10 // Removing 8 -> move 1 to the left
        /// 1234 56|31 0 // Removing 7 -> move 1 to the left
        
        // TODO: Move all this logic to the formatter itself
        
        let updatedText = text.replacingCharacters(in: textRange, with: string)

        // TODO: If the cursor is after a space (because the user placed it there) we have to be able to move the cursor to the left
        
        let sanitizedText = formatter?.sanitizedValue(for: updatedText) ?? updatedText
        let formattedText = formatter?.formattedValue(for: sanitizedText) ?? sanitizedText
        
        let oldCursorOffset = textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.end)
        
        var replacementLength: Int = string.replacingOccurrences(of: " ", with: "").count
        
        if let rangeIndexes = Range(range, in: text) {
            let replacedText = text[rangeIndexes]
            replacementLength -= replacedText.replacingOccurrences(of: " ", with: "").count
        } else {
            replacementLength -= range.length
        }
        
        let isAdding = formattedText.count > text.count
        
        func numberOfSpaces(in text: String, beforeOffset offset: Int) -> Int {
            max(0, text.prefix(max(0, offset)).split(separator: " ").count - 1)
        }
        
        let oldNumberOfSpacesBeforeCursor = numberOfSpaces(
            in: text,
            beforeOffset: oldCursorOffset
        )
        
        let newNumberOfSpacesBeforeCursor = numberOfSpaces(
            in: formattedText,
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
}

private extension [PhoneExtension] {
    
    func preselectedPhoneNumberPrefix(for phoneNumber: PhoneNumber?) -> PhoneExtension {
        
        if let matchingCallingCode = first(where: { $0.value == phoneNumber?.callingCode }) {
            return matchingCallingCode
        }
        
        if let matchingLocaleRegion = first(where: { $0.countryCode == Locale.current.regionCode }) {
            return matchingLocaleRegion
        }
        
        if let firstSelectableValue = first {
            return firstSelectableValue
        }
        
        AdyenAssertion.assertionFailure(message: "Empty list of selectableValues provided")
        return .init(value: "+1", countryCode: "US")
    }
}
