//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

extension CardViewController {

    internal struct ItemsProvider {

        private let formStyle: FormComponentStyle

        private let amount: Amount?

        private var localizationParameters: LocalizationParameters?

        private let configuration: CardComponent.Configuration

        private let shopperInformation: PrefilledShopperInformation?

        private let cardLogos: [FormCardLogosItem.CardTypeLogo]

        private let scope: String

        private let initialCountry: String
        
        private let addressViewModelBuilder: AddressViewModelBuilder
        
        private let presenter: ViewControllerPresenting
        
        private let addressMode: CardComponent.AddressFormType

        internal init(
            formStyle: FormComponentStyle,
            payment: Payment?,
            configuration: CardComponent.Configuration,
            shopperInformation: PrefilledShopperInformation?,
            cardLogos: [FormCardLogosItem.CardTypeLogo],
            scope: String,
            initialCountryCode: String,
            localizationParameters: LocalizationParameters?,
            addressViewModelBuilder: AddressViewModelBuilder,
            presenter: ViewControllerPresenter,
            addressMode: CardComponent.AddressFormType
        ) {
            self.formStyle = formStyle
            self.amount = payment?.amount
            self.configuration = configuration
            self.shopperInformation = shopperInformation
            self.cardLogos = cardLogos
            self.scope = scope
            self.initialCountry = initialCountryCode
            self.localizationParameters = localizationParameters
            self.addressViewModelBuilder = addressViewModelBuilder
            self.presenter = .init(presenter)
            self.addressMode = addressMode
        }
        
        internal lazy var addressItem: FormItem? = {
            switch addressMode {
            case .lookup(let provider):
                return billingAddressPickerItem(with: provider)
            case .full:
                return billingAddressPickerItem(with: nil)
            case .postalCode:
                return postalCodeItem
            case .none:
                return nil
            }
        }()
        
        private func billingAddressPickerItem(with lookupProvider: AddressLookupProvider?) -> FormAddressPickerItem {
            let identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "billingAddress")
            let prefillAddress = shopperInformation?.billingAddress
            
            let item = FormAddressPickerItem(
                for: .delivery,
                initialCountry: initialCountry,
                prefillAddress: prefillAddress,
                style: formStyle.addressStyle,
                localizationParameters: localizationParameters,
                identifier: identifier,
                addressViewModelBuilder: addressViewModelBuilder,
                presenter: presenter,
                lookupProvider: lookupProvider
            )
            return item
        }

        private var postalCodeItem: FormPostalCodeItem {
            let zipCodeItem = FormPostalCodeItem(style: formStyle.textField, localizationParameters: localizationParameters)
            zipCodeItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "postalCodeItem")
            return zipCodeItem
        }

        internal lazy var numberContainerItem: FormCardNumberContainerItem = {
            let item = FormCardNumberContainerItem(cardTypeLogos: cardLogos,
                                                   showsSupportedCardLogos: configuration.showsSupportedCardLogos,
                                                   style: formStyle.textField,
                                                   localizationParameters: localizationParameters)
            item.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "numberContainerItem")
            return item
        }()

        internal lazy var expiryDateItem: FormCardExpiryDateItem = {
            let expiryDateItem = FormCardExpiryDateItem(style: formStyle.textField,
                                                        localizationParameters: localizationParameters)
            expiryDateItem.localizationParameters = localizationParameters
            expiryDateItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "expiryDateItem")

            return expiryDateItem
        }()

        internal lazy var securityCodeItem: FormCardSecurityCodeItem = {
            let securityCodeItem = FormCardSecurityCodeItem(style: formStyle.textField,
                                                            localizationParameters: localizationParameters)
            securityCodeItem.localizationParameters = localizationParameters
            securityCodeItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "securityCodeItem")
            return securityCodeItem
        }()

        internal lazy var holderNameItem: FormTextInputItem = {
            let holderNameItem = FormTextInputItem(style: formStyle.textField)
            holderNameItem.title = localizedString(.cardNameItemTitle, localizationParameters)
            holderNameItem.placeholder = localizedString(.cardNameItemPlaceholder, localizationParameters)
            holderNameItem.validator = LengthValidator(minimumLength: 1)
            holderNameItem.validationFailureMessage = localizedString(.cardNameItemInvalid, localizationParameters)
            holderNameItem.autocapitalizationType = .words
            holderNameItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "holderNameItem")
            holderNameItem.contentType = .name
            return holderNameItem
        }()

        internal lazy var additionalAuthCodeItem: FormTextInputItem = {
            // Validates birthdate (YYMMDD) or the Corporate registration number (10 digits)
            let kcpValidator = NumericStringValidator(exactLength: 10) || DateValidator(format: DateValidator.Format.kcpFormat)

            var additionalItem = FormTextInputItem(style: formStyle.textField)
            additionalItem.title = localizedString(.cardTaxNumberLabelShort, localizationParameters)
            additionalItem.placeholder = localizedString(.cardTaxNumberPlaceholder, localizationParameters)
            additionalItem.validator = kcpValidator
            additionalItem.validationFailureMessage = localizedString(.cardTaxNumberInvalid, localizationParameters)
            additionalItem.autocapitalizationType = .none
            additionalItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "additionalAuthCodeItem")
            additionalItem.keyboardType = .numberPad
            additionalItem.isVisible = configuration.koreanAuthenticationMode == .show

            return additionalItem
        }()

        internal lazy var additionalAuthPasswordItem: FormTextInputItem = {
            var additionalItem = FormTextInputItem(style: formStyle.textField)
            additionalItem.title = localizedString(.cardEncryptedPasswordLabel, localizationParameters)
            additionalItem.placeholder = localizedString(.cardEncryptedPasswordPlaceholder, localizationParameters)
            additionalItem.validator = LengthValidator(exactLength: 2)
            additionalItem.validationFailureMessage = localizedString(.cardEncryptedPasswordInvalid, localizationParameters)
            additionalItem.autocapitalizationType = .none
            additionalItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "additionalAuthPasswordItem")
            additionalItem.keyboardType = .numberPad
            additionalItem.isVisible = configuration.koreanAuthenticationMode == .show

            return additionalItem
        }()

        internal lazy var socialSecurityNumberItem: FormTextInputItem = {
            var securityNumberItem = FormTextInputItem(style: formStyle.textField)
            securityNumberItem.title = localizedString(.boletoSocialSecurityNumber, localizationParameters)
            securityNumberItem.placeholder = localizedString(.cardBrazilSSNPlaceholder, localizationParameters)
            securityNumberItem.formatter = BrazilSocialSecurityNumberFormatter()
            securityNumberItem.validator = NumericStringValidator(exactLength: 11) || NumericStringValidator(exactLength: 14)
            securityNumberItem.validationFailureMessage = localizedString(.validationAlertTitle, localizationParameters)
            securityNumberItem.autocapitalizationType = .none
            securityNumberItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "socialSecurityNumberItem")
            securityNumberItem.keyboardType = .numberPad
            securityNumberItem.isVisible = configuration.socialSecurityNumberMode == .show
            return securityNumberItem
        }()

        internal lazy var storeDetailsItem: FormToggleItem = {
            let storeDetailsItem = FormToggleItem(style: formStyle.toggle)
            storeDetailsItem.title = localizedString(.cardStoreDetailsButton, localizationParameters)
            storeDetailsItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "storeDetailsItem")
            
            return storeDetailsItem
        }()
        
        /// If there is a configuration for installments, this item is created. Otherwise it will be nil.
        internal lazy var installmentsItem: FormCardInstallmentsItem? = {
            guard let installmentsConfiguration = configuration.installmentConfiguration else { return nil }
            let installmentsItem = FormCardInstallmentsItem(installmentConfiguration: installmentsConfiguration,
                                                            style: formStyle.textField,
                                                            amount: amount,
                                                            localizationParameters: localizationParameters)
            installmentsItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "installmentsItem")
            return installmentsItem
        }()

        internal lazy var button: FormButtonItem = {
            let item = FormButtonItem(style: formStyle.mainButtonItem)
            item.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "payButtonItem")
            item.title = localizedSubmitButtonTitle(with: amount,
                                                    style: .immediate,
                                                    localizationParameters)
            return item
        }()

    }

}

internal class ViewControllerPresenting: ViewControllerPresenter {
    
    private weak var presenter: ViewControllerPresenter?
    
    internal init(_ presenter: ViewControllerPresenter) {
        self.presenter = presenter
    }
    
    internal func presentViewController(_ viewController: UIViewController, animated: Bool) {
        presenter?.presentViewController(viewController, animated: animated)
    }
    
    internal func dismissViewController(animated: Bool) {
        presenter?.dismissViewController(animated: animated)
    }
}
