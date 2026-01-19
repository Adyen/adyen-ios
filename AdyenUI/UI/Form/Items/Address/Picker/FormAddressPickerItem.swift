//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

package final class FormAddressPickerItem: FormSelectableValueItem<PostalAddress?> {

    package enum AddressType {
        case billing
        case delivery
    }
    
    private var initialCountry: String
    private let theme: AdyenTheme
    private var context: AddressViewModelBuilderContext
    private let localizationParameters: LocalizationParameters?
    private let addressViewModelBuilder: AddressViewModelBuilder
    private weak var presenter: ViewControllerPresenter?
    
    package var addressViewModel: AddressViewModel {
        addressViewModelBuilder.build(context: self.context)
    }
    
    override package var value: PostalAddress? {
        didSet {
            updateContext()
            updateValidationFailureMessage()
            updateFormattedValue()
        }
    }

    package init(
        for addressType: AddressType,
        initialCountry: String,
        supportedCountryCodes: [String]?,
        prefillAddress: PostalAddress?,
        theme: AdyenTheme = .default,
        style: FormComponentStyle,
        localizationParameters: LocalizationParameters? = nil,
        identifier: String? = nil,
        addressViewModelBuilder: AddressViewModelBuilder = DefaultAddressViewModelBuilder(),
        presenter: ViewControllerPresenter,
        lookupProvider: AddressLookupProvider? = nil
    ) {
        self.initialCountry = initialCountry
        self.theme = theme
        self.addressViewModelBuilder = addressViewModelBuilder
        self.localizationParameters = localizationParameters
        self.context = .init(countryCode: prefillAddress?.country ?? initialCountry, isOptional: false)
        
        super.init(
            value: prefillAddress,
            style: style.addressStyle.textField,
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
                with: self.value,
                theme: self.theme,
                initialCountry: initialCountry,
                supportedCountryCodes: supportedCountryCodes,
                lookupProvider: lookupProvider,
                presenter: presenter,
                style: style
            ) { [weak self] newValue in
                guard let newValue else { return }
                self?.value = newValue
            }
        }
    }

    package func updateOptionalStatus(isOptional: Bool) {
        context.isOptional = isOptional
    }

    override package func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

    // MARK: ValidatableFormItem

    override package func isValid() -> Bool {
        if context.isOptional {
            return true
        }
        guard let address = value else { return false }
        return address.satisfies(requiredFields: addressViewModel.requiredFields)
    }

    override package func validationStatus() -> ValidationStatus? {
        nil
    }
}

// MARK: - Convenience

extension FormAddressPickerItem {

    private func updateContext() {
        guard let country = value?.country else { return }
        context.countryCode = country
    }

    private func updateValidationFailureMessage() {
        validationFailureMessage = {
            if value == nil {
                return localizedString(
                    .addressLookupItemValidationFailureMessageEmpty, localizationParameters
                )
            } else {
                return localizedString(
                    .addressLookupItemValidationFailureMessageInvalid, localizationParameters
                )
            }
        }()
    }

    private func updateFormattedValue() {
        formattedValue = value?.formatted(using: localizationParameters)
    }
}

// MARK: - Picker Presentation

extension FormAddressPickerItem {

    // swiftlint:disable function_parameter_count
    private func didSelectAddressPicker(
        for addressType: FormAddressPickerItem.AddressType,
        with prefillAddress: PostalAddress?,
        theme: AdyenTheme = .default,
        initialCountry: String,
        supportedCountryCodes: [String]?,
        lookupProvider: AddressLookupProvider?,
        presenter: ViewControllerPresenter,
        style: FormComponentStyle,
        completion: @escaping (PostalAddress?) -> Void
    ) {
        // swiftlint:enable function_parameter_count
        let securedViewController = SecuredViewController(
            child: addressPickerViewController(
                for: addressType,
                with: prefillAddress,
                theme: theme,
                initialCountry: initialCountry,
                supportedCountryCodes: supportedCountryCodes,
                lookupProvider: lookupProvider,
                style: style,
                completionHandler: { [weak presenter] address in
                    completion(address)
                    presenter?.dismissViewController(animated: true)
                }
            ),
            style: style
        )

        presenter.presentViewController(securedViewController, animated: true)
    }

    // swiftlint:disable function_parameter_count
    private func addressPickerViewController(
        for addressType: FormAddressPickerItem.AddressType,
        with prefillAddress: PostalAddress?,
        theme: AdyenTheme = .default,
        initialCountry: String,
        supportedCountryCodes: [String]?,
        lookupProvider: AddressLookupProvider?,
        style: FormComponentStyle,
        completionHandler: @escaping (PostalAddress?) -> Void
    ) -> UIViewController {
        // swiftlint:enable function_parameter_count

        guard let lookupProvider else {

            let viewModel = AddressInputFormViewController.ViewModel(
                for: addressType,
                style: style,
                theme: theme,
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
            style: .init(form: style),
            theme: theme,
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

extension FormAddressPickerItem.AddressType {

    package func placeholder(with localizationParameters: LocalizationParameters?) -> String {
        switch self {
        case .billing: return localizedString(.billingAddressPlaceholder, localizationParameters)
        case .delivery: return localizedString(.deliveryAddressPlaceholder, localizationParameters)
        }
    }

    package func title(with localizationParameters: LocalizationParameters?) -> String {
        localizedString(.addressFieldTitle, localizationParameters)
    }
    
    package func sectionTitle(with localizationParameters: LocalizationParameters?) -> String {
        switch self {
        case .billing: return localizedString(.billingAddressSectionTitle, localizationParameters)
        case .delivery: return localizedString(.deliveryAddressSectionTitle, localizationParameters)
        }
    }
}
