//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An address form item for address lookup.
@_spi(AdyenInternal)
public final class FormAddressLookupItem: FormSelectableValueItem<PostalAddress?> {
    
    private var initialCountry: String
    private var context: AddressViewModelBuilderContext
    private let localizationParameters: LocalizationParameters?
    
    /// The view model to validate the address with
    @_spi(AdyenInternal)
    public var addressViewModel: AddressViewModel {
        addressViewModelBuilder.build(context: self.context)
    }
    
    private let addressViewModelBuilder: AddressViewModelBuilder
    
    override public var value: PostalAddress? {
        didSet {
            updateValidationFailureMessage()
            updateFormattedValue()
        }
    }

    /// Initializes the split text item.
    /// - Parameters:
    ///   - initialCountry: The items displayed side-by-side. Must be two.
    ///   - prefillAddress: The provided prefill address
    ///   - style: The `AddressStyle` UI style.
    ///   - localizationParameters: The localization parameters
    ///   - identifier: The item identifier
    ///   - addressViewModelBuilder: The builder to build the Address ViewModel
    public init(
        initialCountry: String,
        prefillAddress: PostalAddress?,
        style: AddressStyle,
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil,
        addressViewModelBuilder: AddressViewModelBuilder
    ) {
        self.initialCountry = initialCountry
        self.addressViewModelBuilder = addressViewModelBuilder
        self.localizationParameters = localizationParameters
        self.context = .init(countryCode: prefillAddress?.country ?? initialCountry, isOptional: false)
        
        super.init(
            value: prefillAddress,
            style: style.textField,
            placeholder: "Enter your billing address" // TODO: Alex - Localization
        )
        
        self.identifier = identifier
        self.title = localizedString(.billingAddressSectionTitle, localizationParameters)
        
        updateValidationFailureMessage()
        updateFormattedValue()
    }
    
    public func updateOptionalStatus(isOptional: Bool) {
        context.isOptional = isOptional
    }
    
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    // MARK: ValidatableFormItem
    
    override public func isValid() -> Bool {
        guard let address = value else { return false }
        return address.satisfies(requiredFields: addressViewModel.requiredFields)
    }
}

// MARK: - Convenience

private extension FormAddressLookupItem {
    
    func updateValidationFailureMessage() {
        validationFailureMessage = (value != nil) ? "Invalid Address" : "Address required" // TODO: Alex - Localization
    }
    
    func updateFormattedValue() {
        formattedValue = value?.formatted(using: localizationParameters)
    }
}