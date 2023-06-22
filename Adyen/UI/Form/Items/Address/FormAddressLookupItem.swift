//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An address form item for address lookup.
@_spi(AdyenInternal)
public final class FormAddressLookupItem: FormValueItem<PostalAddress?, FormTextItemStyle>, AdyenObserver, ValidatableFormItem, Hidable {
    
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    public let localizationParameters: LocalizationParameters?
    
    private var initialCountry: String
    
    @_spi(AdyenInternal)
    public var addressViewModel: AddressViewModel {
        addressViewModelBuilder.build(
            context: .init(
                countryCode: value?.country ?? initialCountry,
                isOptional: false
            )
        )
    }
    
    private let addressViewModelBuilder: AddressViewModelBuilder
    
    override public var value: PostalAddress? {
        didSet {
            updateValidationFailureMessage()
        }
    }
    
    /// A closure that will be invoked when the item is selected.
    public var selectionHandler: (() -> Void)?

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
        self.localizationParameters = localizationParameters
        self.addressViewModelBuilder = addressViewModelBuilder
        super.init(value: prefillAddress, style: style.textField)
        self.identifier = identifier
        self.title = localizedString(.billingAddressSectionTitle, localizationParameters)
        
        updateValidationFailureMessage()
    }
    
    // MARK: - Public
    
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    /// Resets the item's value to an empty `PostalAddress`.
    public func reset() {
        value = PostalAddress()
    }

    public func updateValidationFailureMessage() {
        // TODO: Localization
        validationFailureMessage = (value != nil) ? "Invalid Address" : "Address required"
    }
    
    @AdyenObservable(nil) public var validationFailureMessage: String?
    
    public func isValid() -> Bool {
        guard let address = value else { return false }
        return address.satisfies(requiredFields: addressViewModel.requiredFields)
    }
}
