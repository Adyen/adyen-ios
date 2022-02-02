//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension CardViewController {

    internal struct ItemsProvider {

        private let formStyle: FormComponentStyle

        private let payment: Payment?

        private var localizationParameters: LocalizationParameters?

        private let configuration: CardComponent.Configuration

        private let shopperInformation: PrefilledShopperInformation?

        private let cardLogos: [FormCardLogosItem.CardTypeLogo]

        private let scope: String

        private let defaultCountryCode: String

        internal init(formStyle: FormComponentStyle,
                      payment: Payment?,
                      configuration: CardComponent.Configuration,
                      shopperInformation: PrefilledShopperInformation?,
                      cardLogos: [FormCardLogosItem.CardTypeLogo],
                      scope: String,
                      defaultCountryCode: String,
                      localizationParameters: LocalizationParameters?) {
            self.formStyle = formStyle
            self.payment = payment
            self.configuration = configuration
            self.shopperInformation = shopperInformation
            self.cardLogos = cardLogos
            self.scope = scope
            self.defaultCountryCode = defaultCountryCode
            self.localizationParameters = localizationParameters
        }

        internal lazy var billingAddressItem: FormAddressItem = {
            let identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "billingAddress")

            // check and match the initial country from shopper prefill info
            // with the supported countries
            let initialCountry: String?
            if let countryCodes = configuration.billingAddressCountryCodes, !countryCodes.isEmpty {
                if let prefillCountryCode = shopperInformation?.billingAddress?.country,
                   countryCodes.contains(prefillCountryCode) {
                    initialCountry = prefillCountryCode
                } else {
                    initialCountry = countryCodes.first
                }
            } else {
                initialCountry = shopperInformation?.billingAddress?.country
            }
            
            let item = FormAddressItem(initialCountry: initialCountry ?? defaultCountryCode,
                                       style: formStyle.addressStyle,
                                       localizationParameters: localizationParameters,
                                       identifier: identifier,
                                       supportedCountryCodes: configuration.billingAddressCountryCodes)
            shopperInformation?.billingAddress.map { item.value = $0 }
            item.style.backgroundColor = UIColor.Adyen.lightGray
            return item
        }()

        internal lazy var postalCodeItem: FormTextItem = {
            let zipCodeItem = FormTextInputItem(style: formStyle.textField)
            zipCodeItem.title = localizedString(.postalCodeFieldTitle, localizationParameters)
            zipCodeItem.placeholder = localizedString(.postalCodeFieldPlaceholder, localizationParameters)
            zipCodeItem.validator = LengthValidator(minimumLength: 2, maximumLength: 30)
            zipCodeItem.validationFailureMessage = localizedString(.validationAlertTitle, localizationParameters)
            zipCodeItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "postalCodeItem")
            zipCodeItem.contentType = .postalCode
            return zipCodeItem
        }()

        internal lazy var numberContainerItem: FormCardNumberContainerItem = {
            let item = FormCardNumberContainerItem(cardTypeLogos: cardLogos,
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
            holderNameItem.validator = LengthValidator(minimumLength: 2)
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
                                                            amount: payment?.amount,
                                                            localizationParameters: localizationParameters)
            installmentsItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "installmentsItem")
            return installmentsItem
        }()

        internal lazy var button: FormButtonItem = {
            let item = FormButtonItem(style: formStyle.mainButtonItem)
            item.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "payButtonItem")
            item.title = localizedSubmitButtonTitle(with: payment?.amount,
                                                    style: .immediate,
                                                    localizationParameters)
            return item
        }()

    }

}
