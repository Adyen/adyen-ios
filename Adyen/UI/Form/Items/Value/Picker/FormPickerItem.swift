//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A wrapper struct to use as item in ``FormPickerItem``
@_spi(AdyenInternal)
public struct FormPickable: Equatable {
    
    public let identifier: String
    public let icon: UIImage?
    public let title: String
    public let subtitle: String?
    
    public init(
        identifier: String,
        icon: UIImage? = nil,
        title: String,
        subtitle: String?
    ) {
        self.identifier = identifier
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}

/// An form item for picking values.
@_spi(AdyenInternal)
open class FormPickerItem: FormSelectableValueItem<FormPickable?> {
    
    public let localizationParameters: LocalizationParameters?
    public private(set) var isOptional: Bool = false
    
    override public var value: FormPickable? {
        didSet {
            updateValidationFailureMessage()
            updateFormattedValue()
        }
    }
    
    @AdyenObservable([])
    public var selectableValues: [FormPickable]

    /// Initializes the form picker item item.
    /// - Parameters:
    ///   - prefillValue: The value to prefill.
    ///   - selectableValues: The selectable values.
    ///   - title: The title of the screen
    ///   - placeholder: The placeholder of the item when the value is `nil`
    ///   - style: The `FormTextItemStyle` UI style.
    ///   - localizationParameters: The localization parameters.
    ///   - identifier: The item identifier
    public init(
        preselectedValue: FormPickable?,
        selectableValues: [FormPickable],
        title: String,
        placeholder: String,
        style: FormTextItemStyle,
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil
    ) {
        self.localizationParameters = localizationParameters

        super.init(
            value: preselectedValue,
            style: style,
            placeholder: placeholder
        )
        
        self.selectableValues = selectableValues
        
        self.identifier = identifier
        self.title = title
        
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
        guard let value else { return false }
        return selectableValues.contains { $0.identifier == value.identifier }
    }
    
    public func updateValidationFailureMessage() {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
    }
    
    public func updateFormattedValue() {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
    }
}
