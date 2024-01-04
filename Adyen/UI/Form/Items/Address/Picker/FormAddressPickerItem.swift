//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An address form item that allows picking an address on a separate screen.
@_spi(AdyenInternal)
public final class FormAddressPickerItem: FormSelectableValueItem<PostalAddress?>, Hidable {
    
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    public enum AddressType {
        case billing
        case delivery
    }
    
    private var initialCountry: String
    private var context: AddressViewModelBuilderContext
    private let localizationParameters: LocalizationParameters?
    private let addressViewModelBuilder: AddressViewModelBuilder
    private weak var presenter: ViewControllerPresenter?
    
    /// The view model to validate the address with
    @_spi(AdyenInternal)
    public var addressViewModel: AddressViewModel {
        addressViewModelBuilder.build(context: self.context)
    }
    
    override public var value: PostalAddress? {
        didSet {
            updateContext()
            updateValidationFailureMessage()
            updateFormattedValue()
        }
    }

    /// Initializes the address lookup item.
    /// - Parameters:
    ///   - addressType: The type of address to pick
    ///   - initialCountry: The items displayed side-by-side. Must be two.
    ///   - prefillAddress: The provided prefill address
    ///   - style: The `AddressStyle` UI style.
    ///   - localizationParameters: The localization parameters
    ///   - identifier: The item identifier
    ///   - addressViewModelBuilder: The builder to build the Address ViewModel
    public init(
        for addressType: AddressType,
        initialCountry: String,
        supportedCountryCodes: [String]?,
        prefillAddress: PostalAddress?,
        style: AddressStyle, // TODO: Custom style that also takes the form style
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil,
        addressViewModelBuilder: AddressViewModelBuilder = DefaultAddressViewModelBuilder(),
        presenter: ViewControllerPresenter?,
        lookupProvider: AddressLookupProvider? = nil
    ) {
        self.initialCountry = initialCountry
        self.addressViewModelBuilder = addressViewModelBuilder
        self.localizationParameters = localizationParameters
        self.context = .init(countryCode: prefillAddress?.country ?? initialCountry, isOptional: false)
        
        super.init(
            value: prefillAddress,
            style: style.textField,
            placeholder: addressType.placeholder(with: localizationParameters)
        )
        
        self.identifier = identifier
        self.title = addressType.title(with: localizationParameters)
        
        updateValidationFailureMessage()
        updateFormattedValue()
        
        selectionHandler = { [weak self, weak presenter] in
            guard let self, let presenter else { return }
            
            self.didSelectAddressPicker(
                for: addressType,
                with: prefillAddress,
                initialCountry: initialCountry,
                supportedCountryCodes: supportedCountryCodes,
                lookupProvider: lookupProvider,
                presenter: presenter
            ) { [weak self] in self?.value = $0 }
        }
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

// MARK: - Picker Presentation

extension FormAddressPickerItem {
    
    private func didSelectAddressPicker(
        for addressType: FormAddressPickerItem.AddressType,
        with prefillAddress: PostalAddress?,
        initialCountry: String,
        supportedCountryCodes: [String]?,
        lookupProvider: AddressLookupProvider?,
        presenter: ViewControllerPresenter,
        completion: @escaping (PostalAddress?) -> Void
    ) {
        let securedViewController = SecuredViewController(
            child: addressPickerViewController(
                for: addressType,
                with: prefillAddress,
                initialCountry: initialCountry,
                supportedCountryCodes: supportedCountryCodes,
                lookupProvider: lookupProvider,
                completionHandler: { [weak self, weak presenter] address in
                    guard let self else { return }
                    completion(address)
                    presenter?.dismissViewController(animated: true)
                }
            ),
            style: style
        )
        
        presenter.presentViewController(securedViewController, animated: true)
    }
    
    private func addressPickerViewController(
        for addressType: FormAddressPickerItem.AddressType,
        with prefillAddress: PostalAddress?,
        initialCountry: String,
        supportedCountryCodes: [String]?,
        lookupProvider: AddressLookupProvider?,
        completionHandler: @escaping (PostalAddress?) -> Void
    ) -> UIViewController {
        
        guard let lookupProvider else {
        
            let viewModel = AddressInputFormViewController.ViewModel(
                for: addressType,
                style: .init(), // style, // TODO: Provide correct style!
                localizationParameters: localizationParameters,
                initialCountry: initialCountry,
                prefillAddress: prefillAddress,
                supportedCountryCodes: supportedCountryCodes,
                addressViewModelBuilder: addressViewModelBuilder,
                handleShowSearch: nil,
                completionHandler: completionHandler
            )
            
            return UINavigationController(
                rootViewController: AddressInputFormViewController(viewModel: viewModel)
            )
        }

        let viewModel = AddressLookupViewController.ViewModel(
            for: addressType,
            style: .init(), // configuration.style, // TODO: Provide correct style!
            localizationParameters: localizationParameters,
            supportedCountryCodes: supportedCountryCodes,
            initialCountry: initialCountry,
            prefillAddress: prefillAddress,
            lookupProvider: lookupProvider,
            completionHandler: completionHandler
        )

        return AddressLookupViewController(viewModel: viewModel)
    }
}

// MARK: - AddressType

public extension FormAddressPickerItem.AddressType {
    
    func placeholder(with localizationParameters: LocalizationParameters?) -> String {
        switch self {
        case .billing: return localizedString(.billingAddressPlaceholder, localizationParameters)
        case .delivery: return "DELIVERY" // localizedString(.deliveryAddressPlaceholder, localizationParameters) // TODO: Get translations
        }
    }
    
    func title(with localizationParameters: LocalizationParameters?) -> String {
        switch self {
        case .billing: localizedString(.billingAddressSectionTitle, localizationParameters)
        case .delivery: localizedString(.deliveryAddressSectionTitle, localizationParameters)
        }
    }
}
