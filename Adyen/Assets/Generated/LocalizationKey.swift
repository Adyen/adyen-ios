//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// :nodoc:
public struct LocalizationKey {

    /// Pay
    public static let submitButton = LocalizationKey(key: "adyen.submitButton")
    /// Pay %@
    public static let submitButtonFormatted = LocalizationKey(key: "adyen.submitButton.formatted")
    /// Cancel
    public static let cancelButton = LocalizationKey(key: "adyen.cancelButton")
    /// OK
    public static let dismissButton = LocalizationKey(key: "adyen.dismissButton")
    /// Error
    public static let errorTitle = LocalizationKey(key: "adyen.error.title")
    /// An unknown error occurred
    public static let errorUnknown = LocalizationKey(key: "adyen.error.unknown")
    /// Invalid Input
    public static let validationAlertTitle = LocalizationKey(key: "adyen.validationAlert.title")
    /// others
    public static let paymentMethodsOtherMethods = LocalizationKey(key: "adyen.paymentMethods.otherMethods")
    /// Stored
    public static let paymentMethodsStoredMethods = LocalizationKey(key: "adyen.paymentMethods.storedMethods")
    /// Payment Methods
    public static let paymentMethodsTitle = LocalizationKey(key: "adyen.paymentMethods.title")
    /// Account Number (IBAN)
    public static let sepaIbanItemTitle = LocalizationKey(key: "adyen.sepa.ibanItem.title")
    /// Invalid account number
    public static let sepaIbanItemInvalid = LocalizationKey(key: "adyen.sepa.ibanItem.invalid")
    /// Holder Name
    public static let sepaNameItemTitle = LocalizationKey(key: "adyen.sepa.nameItem.title")
    /// J. Smith
    public static let sepaNameItemPlaceholder = LocalizationKey(key: "adyen.sepa.nameItem.placeholder")
    /// By pressing the button above, you agree that the specified amount will be debited from your bank account.
    public static let sepaConsentLabel = LocalizationKey(key: "adyen.sepa.consentLabel")
    /// Holder name invalid
    public static let sepaNameItemInvalid = LocalizationKey(key: "adyen.sepa.nameItem.invalid")
    /// Remember for next time
    public static let cardStoreDetailsButton = LocalizationKey(key: "adyen.card.storeDetailsButton")
    /// Name on card
    public static let cardNameItemTitle = LocalizationKey(key: "adyen.card.nameItem.title")
    /// J. Smith
    public static let cardNameItemPlaceholder = LocalizationKey(key: "adyen.card.nameItem.placeholder")
    /// Invalid cardholder name
    public static let cardNameItemInvalid = LocalizationKey(key: "adyen.card.nameItem.invalid")
    /// Card number
    public static let cardNumberItemTitle = LocalizationKey(key: "adyen.card.numberItem.title")
    /// 1234 5678 9012 3456
    public static let cardNumberItemPlaceholder = LocalizationKey(key: "adyen.card.numberItem.placeholder")
    /// Invalid card number
    public static let cardNumberItemInvalid = LocalizationKey(key: "adyen.card.numberItem.invalid")
    /// Expiry date
    public static let cardExpiryItemTitle = LocalizationKey(key: "adyen.card.expiryItem.title")
    /// Expiry date (optional)
    public static let cardExpiryItemTitleOptional = LocalizationKey(key: "adyen.card.expiryItem.title.optional")
    /// MM/YY
    public static let cardExpiryItemPlaceholder = LocalizationKey(key: "adyen.card.expiryItem.placeholder")
    /// Invalid expiry date
    public static let cardExpiryItemInvalid = LocalizationKey(key: "adyen.card.expiryItem.invalid")
    /// Invalid CVC / CVV format
    public static let cardCvcItemInvalid = LocalizationKey(key: "adyen.card.cvcItem.invalid")
    /// CVC / CVV
    public static let cardCvcItemTitle = LocalizationKey(key: "adyen.card.cvcItem.title")
    /// 123
    public static let cardCvcItemPlaceholder = LocalizationKey(key: "adyen.card.cvcItem.placeholder")
    /// Verify your card
    public static let cardStoredTitle = LocalizationKey(key: "adyen.card.stored.title")
    /// Please enter the CVC code for %@
    public static let cardStoredMessage = LocalizationKey(key: "adyen.card.stored.message")
    /// Expires %@
    public static let cardStoredExpires = LocalizationKey(key: "adyen.card.stored.expires")
    /// %@ isn't supported
    public static let cardNumberItemUnsupportedBrand = LocalizationKey(key: "adyen.card.numberItem.unsupportedBrand")
    /// The entered card brand isn't supported
    public static let cardNumberItemUnknownBrand = LocalizationKey(key: "adyen.card.numberItem.unknownBrand")
    /// Confirm %@ payment
    public static let dropInStoredTitle = LocalizationKey(key: "adyen.dropIn.stored.title")
    /// Change Payment Method
    public static let dropInPreselectedOpenAllTitle = LocalizationKey(key: "adyen.dropIn.preselected.openAll.title")
    /// Continue to %@
    public static let continueTo = LocalizationKey(key: "adyen.continueTo")
    /// Continue
    public static let continueTitle = LocalizationKey(key: "adyen.continueTitle")
    /// Telephone number
    public static let phoneNumberTitle = LocalizationKey(key: "adyen.phoneNumber.title")
    /// Invalid telephone number
    public static let phoneNumberInvalid = LocalizationKey(key: "adyen.phoneNumber.invalid")
    /// 123–456–789
    public static let phoneNumberPlaceholder = LocalizationKey(key: "adyen.phoneNumber.placeholder")
    /// %@ digits
    public static let cardCvcItemPlaceholderDigits = LocalizationKey(key: "adyen.card.cvcItem.placeholder.digits")
    /// Email address
    public static let emailItemTitle = LocalizationKey(key: "adyen.emailItem.title")
    /// Email address
    public static let emailItemPlaceHolder = LocalizationKey(key: "adyen.emailItem.placeHolder")
    /// Invalid email address
    public static let emailItemInvalid = LocalizationKey(key: "adyen.emailItem.invalid")
    /// More options
    public static let moreOptions = LocalizationKey(key: "adyen.moreOptions")
    /// Confirm your payment on the MB WAY app
    public static let mbwayConfirmPayment = LocalizationKey(key: "adyen.mbway.confirmPayment")
    /// Waiting for confirmation
    public static let awaitWaitForConfirmation = LocalizationKey(key: "adyen.await.waitForConfirmation")
    /// Open your banking app to confirm the payment.
    public static let blikConfirmPayment = LocalizationKey(key: "adyen.blik.confirmPayment")
    /// Enter 6 numbers
    public static let blikInvalid = LocalizationKey(key: "adyen.blik.invalid")
    /// 6-digit code
    public static let blikCode = LocalizationKey(key: "adyen.blik.code")
    /// Get the code from your banking app.
    public static let blikHelp = LocalizationKey(key: "adyen.blik.help")
    /// 123–456
    public static let blikPlaceholder = LocalizationKey(key: "adyen.blik.placeholder")
    /// Preauthorize with %@
    public static let preauthorizeWith = LocalizationKey(key: "adyen.preauthorizeWith")
    /// Confirm preauthorization
    public static let confirmPreauthorization = LocalizationKey(key: "adyen.confirmPreauthorization")
    /// CVC / CVV (optional)
    public static let cardCvcItemTitleOptional = LocalizationKey(key: "adyen.card.cvcItem.title.optional")
    /// Confirm purchase
    public static let confirmPurchase = LocalizationKey(key: "adyen.confirmPurchase")
    /// Last name
    public static let lastName = LocalizationKey(key: "adyen.lastName")
    /// First name
    public static let firstName = LocalizationKey(key: "adyen.firstName")
    /// Pin
    public static let cardPinTitle = LocalizationKey(key: "adyen.card.pin.title")
    /// Incomplete field
    public static let missingField = LocalizationKey(key: "adyen.missingField")
    /// Redeem
    public static let cardApplyGiftcard = LocalizationKey(key: "adyen.card.applyGiftcard")
    /// Collection Institution Number
    public static let voucherCollectionInstitutionNumber = LocalizationKey(key: "adyen.voucher.collectionInstitutionNumber")
    /// Merchant
    public static let voucherMerchantName = LocalizationKey(key: "adyen.voucher.merchantName")
    /// Expiration Date
    public static let voucherExpirationDate = LocalizationKey(key: "adyen.voucher.expirationDate")
    /// Payment Reference
    public static let voucherPaymentReferenceLabel = LocalizationKey(key: "adyen.voucher.paymentReferenceLabel")
    /// Shopper Name
    public static let voucherShopperName = LocalizationKey(key: "adyen.voucher.shopperName")
    /// Copy
    public static let buttonCopy = LocalizationKey(key: "adyen.button.copy")
    /// Thank you for your purchase, please use the following information to complete your payment.
    public static let voucherIntroduction = LocalizationKey(key: "adyen.voucher.introduction")
    /// Read instructions
    public static let voucherReadInstructions = LocalizationKey(key: "adyen.voucher.readInstructions")
    /// Save as image
    public static let voucherSaveImage = LocalizationKey(key: "adyen.voucher.saveImage")
    /// Finish
    public static let voucherFinish = LocalizationKey(key: "adyen.voucher.finish")
    /// 123.123.123-12
    public static let cardBrazilSSNPlaceholder = LocalizationKey(key: "adyen.card.brazilSSN.placeholder")
    /// Amount
    public static let amount = LocalizationKey(key: "adyen.amount")
    /// Entity
    public static let voucherEntity = LocalizationKey(key: "adyen.voucher.entity")
    /// Open the app with the PIX registered key, choose Pay with PIX and scan the QR Code or copy and paste the code
    public static let pixInstructions = LocalizationKey(key: "adyen.pix.instructions")
    /// You have %@ to pay
    public static let pixExpirationLabel = LocalizationKey(key: "adyen.pix.expirationLabel")
    /// Copy code
    public static let pixCopyButton = LocalizationKey(key: "adyen.pix.copyButton")
    /// Code copied to clipboard
    public static let pixInstructionsCopiedMessage = LocalizationKey(key: "adyen.pix.instructions.copiedMessage")
    /// Billing address
    public static let billingAddressSectionTitle = LocalizationKey(key: "adyen.billingAddressSection.title")
    /// Delivery Address
    public static let deliveryAddressSectionTitle = LocalizationKey(key: "adyen.deliveryAddressSection.title")
    /// Country
    public static let countryFieldTitle = LocalizationKey(key: "adyen.countryField.title")
    /// Address
    public static let addressFieldTitle = LocalizationKey(key: "adyen.addressField.title")
    /// Address
    public static let addressFieldPlaceholder = LocalizationKey(key: "adyen.addressField.placeholder")
    /// Street
    public static let streetFieldTitle = LocalizationKey(key: "adyen.streetField.title")
    /// Street
    public static let streetFieldPlaceholder = LocalizationKey(key: "adyen.streetField.placeholder")
    /// House number
    public static let houseNumberFieldTitle = LocalizationKey(key: "adyen.houseNumberField.title")
    /// House number
    public static let houseNumberFieldPlaceholder = LocalizationKey(key: "adyen.houseNumberField.placeholder")
    /// City
    public static let cityFieldTitle = LocalizationKey(key: "adyen.cityField.title")
    /// City
    public static let cityFieldPlaceholder = LocalizationKey(key: "adyen.cityField.placeholder")
    /// City / Town
    public static let cityTownFieldTitle = LocalizationKey(key: "adyen.cityTownField.title")
    /// City / Town
    public static let cityTownFieldPlaceholder = LocalizationKey(key: "adyen.cityTownField.placeholder")
    /// Postal code
    public static let postalCodeFieldTitle = LocalizationKey(key: "adyen.postalCodeField.title")
    /// Postal code
    public static let postalCodeFieldPlaceholder = LocalizationKey(key: "adyen.postalCodeField.placeholder")
    /// Zip code
    public static let zipCodeFieldTitle = LocalizationKey(key: "adyen.zipCodeField.title")
    /// Zip code
    public static let zipCodeFieldPlaceholder = LocalizationKey(key: "adyen.zipCodeField.placeholder")
    /// State
    public static let stateFieldTitle = LocalizationKey(key: "adyen.stateField.title")
    /// State
    public static let stateFieldPlaceholder = LocalizationKey(key: "adyen.stateField.placeholder")
    /// Select state
    public static let selectStateFieldPlaceholder = LocalizationKey(key: "adyen.selectStateField.placeholder")
    /// State or province
    public static let stateOrProvinceFieldTitle = LocalizationKey(key: "adyen.stateOrProvinceField.title")
    /// State or province
    public static let stateOrProvinceFieldPlaceholder = LocalizationKey(key: "adyen.stateOrProvinceField.placeholder")
    /// Select province or territory
    public static let selectStateOrProvinceFieldPlaceholder = LocalizationKey(key: "adyen.selectStateOrProvinceField.placeholder")
    /// Province or Territory
    public static let provinceOrTerritoryFieldTitle = LocalizationKey(key: "adyen.provinceOrTerritoryField.title")
    /// Province or Territory
    public static let provinceOrTerritoryFieldPlaceholder = LocalizationKey(key: "adyen.provinceOrTerritoryField.placeholder")
    /// Apartment / Suite
    public static let apartmentSuiteFieldTitle = LocalizationKey(key: "adyen.apartmentSuiteField.title")
    /// Apartment / Suite
    public static let apartmentSuiteFieldPlaceholder = LocalizationKey(key: "adyen.apartmentSuiteField.placeholder")
    /// Required field, please fill it in.
    public static let errorFeedbackEmptyField = LocalizationKey(key: "adyen.errorFeedback.emptyField")
    /// Input format is not valid.
    public static let errorFeedbackIncorrectFormat = LocalizationKey(key: "adyen.errorFeedback.incorrectFormat")
    /// (optional)
    public static let fieldTitleOptional = LocalizationKey(key: "adyen.field.title.optional")
    /// Generate Boleto
    public static let boletobancarioBtnLabel = LocalizationKey(key: "adyen.boletobancario.btnLabel")
    /// Send a copy to my email
    public static let boletoSendCopyToEmail = LocalizationKey(key: "adyen.boleto.sendCopyToEmail")
    /// Personal details
    public static let boletoPersonalDetails = LocalizationKey(key: "adyen.boleto.personalDetails")
    /// CPF/CNPJ
    public static let boletoSocialSecurityNumber = LocalizationKey(key: "adyen.boleto.socialSecurityNumber")
    /// Download PDF
    public static let boletoDownloadPdf = LocalizationKey(key: "adyen.boleto.download.pdf")
    /// Gift cards are only valid in the currency they were issued in
    public static let giftcardCurrencyError = LocalizationKey(key: "adyen.giftcard.currencyError")
    /// This gift card has zero balance
    public static let giftcardNoBalance = LocalizationKey(key: "adyen.giftcard.noBalance")
    /// Remaining balance will be %@
    public static let partialPaymentRemainingBalance = LocalizationKey(key: "adyen.partialPayment.remainingBalance")
    /// Select payment method for the remaining %@
    public static let partialPaymentPayRemainingAmount = LocalizationKey(key: "adyen.partialPayment.payRemainingAmount")
    /// Cardholder birthdate (YYMMDD) or Corporate registration number (10 digits)
    public static let cardTaxNumberLabel = LocalizationKey(key: "adyen.card.taxNumber.label")
    /// YYMMDD / 0123456789
    public static let cardTaxNumberPlaceholder = LocalizationKey(key: "adyen.card.taxNumber.placeholder")
    /// Invalid Cardholder birthdate or Corporate registration number
    public static let cardTaxNumberInvalid = LocalizationKey(key: "adyen.card.taxNumber.invalid")
    /// First 2 digits of card password
    public static let cardEncryptedPasswordLabel = LocalizationKey(key: "adyen.card.encryptedPassword.label")
    /// 12
    public static let cardEncryptedPasswordPlaceholder = LocalizationKey(key: "adyen.card.encryptedPassword.placeholder")
    /// Invalid password
    public static let cardEncryptedPasswordInvalid = LocalizationKey(key: "adyen.card.encryptedPassword.invalid")
    /// Birthdate or Corporate registration number
    public static let cardTaxNumberLabelShort = LocalizationKey(key: "adyen.card.taxNumber.label.short")
    /// Separate delivery address
    public static let affirmDeliveryAddressToggleTitle = LocalizationKey(key: "adyen.affirm.deliveryAddressToggle.title")
    /// Shopper Reference
    public static let voucherShopperReference = LocalizationKey(key: "adyen.voucher.shopperReference")
    /// Alternative Reference
    public static let voucherAlternativeReference = LocalizationKey(key: "adyen.voucher.alternativeReference")
    /// Number of installments
    public static let cardInstallmentsNumberOfInstallments = LocalizationKey(key: "adyen.card.installments.numberOfInstallments")
    /// One time payment
    public static let cardInstallmentsOneTime = LocalizationKey(key: "adyen.card.installments.oneTime")
    /// Installments payment
    public static let cardInstallmentsTitle = LocalizationKey(key: "adyen.card.installments.title")
    /// Revolving payment
    public static let cardInstallmentsRevolving = LocalizationKey(key: "adyen.card.installments.revolving")
    /// %@x %@
    public static let cardInstallmentsMonthsAndPrice = LocalizationKey(key: "adyen.card.installments.monthsAndPrice")
    /// %@ months
    public static let cardInstallmentsMonths = LocalizationKey(key: "adyen.card.installments.months")
    /// Method of payment
    public static let cardInstallmentsPlan = LocalizationKey(key: "adyen.card.installments.plan")
    /// Bank account holder name
    public static let bacsHolderNameFieldTitle = LocalizationKey(key: "adyen.bacs.holderNameField.title")
    /// Bank account number
    public static let bacsBankAccountNumberFieldTitle = LocalizationKey(key: "adyen.bacs.bankAccountNumberField.title")
    /// Sort code
    public static let bacsBankLocationIdFieldTitle = LocalizationKey(key: "adyen.bacs.bankLocationIdField.title")
    /// I confirm the account is in my name and I am the only signatory required to authorise the Direct Debit on this account.
    public static let bacsLegalConsentToggleTitle = LocalizationKey(key: "adyen.bacs.legalConsentToggle.title")
    /// I agree that the above amount will be deducted from my bank account.
    public static let bacsAmountConsentToggleTitle = LocalizationKey(key: "adyen.bacs.amountConsentToggle.title")
    /// I agree that %@ will be deducted from my bank account.
    public static let bacsSpecifiedAmountConsentToggleTitle = LocalizationKey(key: "adyen.bacs.specifiedAmountConsentToggle.title")
    /// Invalid bank account holder name
    public static let bacsHolderNameFieldInvalidMessage = LocalizationKey(key: "adyen.bacs.holderNameField.invalidMessage")
    /// Invalid bank account number
    public static let bacsBankAccountNumberFieldInvalidMessage = LocalizationKey(key: "adyen.bacs.bankAccountNumberField.invalidMessage")
    /// Invalid sort code
    public static let bacsBankLocationIdFieldInvalidMessage = LocalizationKey(key: "adyen.bacs.bankLocationIdField.invalidMessage")
    /// Confirm and pay
    public static let bacsPaymentButtonTitle = LocalizationKey(key: "adyen.bacs.paymentButton.title")
    /// Download your Direct Debit Instruction (DDI / Mandate)
    public static let bacsDownloadMandate = LocalizationKey(key: "adyen.bacs.downloadMandate")
    /// Bank account
    public static let achBankAccountTitle = LocalizationKey(key: "adyen.ach.bankAccount.title")
    /// Account holder name
    public static let achAccountHolderNameFieldTitle = LocalizationKey(key: "adyen.ach.accountHolderNameField.title")
    /// Invalid account holder name
    public static let achAccountHolderNameFieldInvalid = LocalizationKey(key: "adyen.ach.accountHolderNameField.invalid")
    /// Account number
    public static let achAccountNumberFieldTitle = LocalizationKey(key: "adyen.ach.accountNumberField.title")
    /// Invalid account number
    public static let achAccountNumberFieldInvalid = LocalizationKey(key: "adyen.ach.accountNumberField.invalid")
    /// ABA routing number
    public static let achAccountLocationFieldTitle = LocalizationKey(key: "adyen.ach.accountLocationField.title")
    /// Invalid ABA routing number
    public static let achAccountLocationFieldInvalid = LocalizationKey(key: "adyen.ach.accountLocationField.invalid")
    
    internal let key: String
    
    /// :nodoc:
    public init(key: String) {
        self.key = key
    }

}
