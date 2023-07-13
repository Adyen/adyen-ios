//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public protocol FormPickable: Equatable {
    
    var identifier: String { get }
    
    var displayIcon: UIImage? { get }
    var displayTitle: String { get }
    var displaySubtitle: String? { get }
}

/// An address form item for address lookup.
@_spi(AdyenInternal)
open class FormPickerItem<ValueType: FormPickable>: FormSelectableValueItem<ValueType?> {
    
    public let localizationParameters: LocalizationParameters?
    public private(set) var isOptional: Bool = false
    
    override public var value: ValueType? {
        didSet {
            updateValidationFailureMessage()
            updateFormattedValue()
        }
    }
    
    @AdyenObservable([])
    public var selectableValues: [ValueType]

    /// Initializes the split text item.
    /// - Parameters:
    ///   - prefillRegion: The provided prefill region
    ///   - style: The `FormTextItemStyle` UI style.
    ///   - localizationParameters: The localization parameters
    ///   - identifier: The item identifier
    public init(
        prefillValue: ValueType?,
        selectableValues: [ValueType],
        title: String,
        placeholder: String,
        style: FormTextItemStyle,
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil
    ) {
        self.localizationParameters = localizationParameters

        super.init(
            value: prefillValue,
            style: style,
            placeholder: placeholder
        )
        
        self.selectableValues = selectableValues
        
        self.identifier = identifier
        self.title = localizedString(.countryFieldTitle, localizationParameters)
        
        updateValidationFailureMessage()
        updateFormattedValue()
    }
    
    public func updateOptionalStatus(isOptional: Bool) {
        self.isOptional = isOptional
    }
    
    public func resetValue() {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
    }
    
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    // MARK: ValidatableFormItem
    
    override public func isValid() -> Bool {
        if isOptional { return true }
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
        return false
    }
    
    public func updateValidationFailureMessage() {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
    }
    
    public func updateFormattedValue() {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
    }
}
