//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An address form item that allows picking an address on a separate screen.
@_spi(AdyenInternal)
public final class FormAddressPickerItem: FormSelectableValueItem<PostalAddress?> {
    
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
            updateContext()
            updateValidationFailureMessage()
            updateFormattedValue()
        }
    }

    /// Initializes the address lookup item.
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
            placeholder: localizedString(.billingAddressPlaceholder, localizationParameters)
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
        if context.isOptional {
            return true
        }
        guard let address = value else { return false }
        return address.satisfies(requiredFields: addressViewModel.requiredFields)
    }
}

// MARK: - Convenience

private extension FormAddressPickerItem {
    
    func updateContext() {
        guard let country = value?.country else { return }
        context.countryCode = country
    }
    
    func updateValidationFailureMessage() {
        validationFailureMessage = {
            if value == nil {
                return localizedString(.addressLookupItemValidationFailureMessageEmpty, localizationParameters)
            } else {
                return localizedString(.addressLookupItemValidationFailureMessageInvalid, localizationParameters)
            }
        }()
    }
    
    func updateFormattedValue() {
        formattedValue = value?.formatted(using: localizationParameters)
    }
}
