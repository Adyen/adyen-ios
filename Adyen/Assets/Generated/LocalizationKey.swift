//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// swiftlint:disable all
package struct LocalizationKey {

    /// Pay
    package static let submitButton = LocalizationKey(key: "adyen.submitButton")
    /// Pay %@
    package static let submitButtonFormatted = LocalizationKey(key: "adyen.submitButton.formatted")
    /// Cancel
    package static let cancelButton = LocalizationKey(key: "adyen.cancelButton")
    /// OK
    package static let dismissButton = LocalizationKey(key: "adyen.dismissButton")
    /// Remove
    package static let removeButton = LocalizationKey(key: "adyen.removeButton")
    /// Error
    package static let errorTitle = LocalizationKey(key: "adyen.error.title")
    /// An unknown error occurred
    package static let errorUnknown = LocalizationKey(key: "adyen.error.unknown")
    /// Invalid Input
    package static let validationAlertTitle = LocalizationKey(key: "adyen.validationAlert.title")
    /// Others
    package static let paymentMethodsOtherMethods = LocalizationKey(key: "adyen.paymentMethods.otherMethods")
    /// Stored
    package static let paymentMethodsStoredMethods = LocalizationKey(key: "adyen.paymentMethods.storedMethods")
    /// Applied
    package static let paymentMethodsPaidMethods = LocalizationKey(key: "adyen.paymentMethods.paidMethods")
    /// Payment Methods
    package static let paymentMethodsTitle = LocalizationKey(key: "adyen.paymentMethods.title")
    /// Yes, remove
    package static let paymentMethodRemoveButton = LocalizationKey(key: "adyen.paymentMethod.removeButton")
    /// The payment was refused. Please try again.
    package static let paymentRefusedMessage = LocalizationKey(key: "adyen.payment.refused.message")
    /// Account Number (IBAN)
    package static let sepaIbanItemTitle = LocalizationKey(key: "adyen.sepa.ibanItem.title")
    /// Invalid account number
    package static let sepaIbanItemInvalid = LocalizationKey(key: "adyen.sepa.ibanItem.invalid")
    /// Holder Name
    package static let sepaNameItemTitle = LocalizationKey(key: "adyen.sepa.nameItem.title")
    /// J. Smith
    package static let sepaNameItemPlaceholder = LocalizationKey(key: "adyen.sepa.nameItem.placeholder")
    /// By pressing the button above, you agree that the specified amount will be debited from your bank account.
    package static let sepaConsentLabel = LocalizationKey(key: "adyen.sepa.consentLabel")
    /// Holder name invalid
    package static let sepaNameItemInvalid = LocalizationKey(key: "adyen.sepa.nameItem.invalid")
    /// Remember for next time
    package static let cardStoreDetailsButton = LocalizationKey(key: "adyen.card.storeDetailsButton")
    /// Name on card
    package static let cardNameItemTitle = LocalizationKey(key: "adyen.card.nameItem.title")
    /// J. Smith
    package static let cardNameItemPlaceholder = LocalizationKey(key: "adyen.card.nameItem.placeholder")
    /// Enter name as shown on card
    package static let cardNameItemInvalid = LocalizationKey(key: "adyen.card.nameItem.invalid")
    /// Card number
    package static let cardNumberItemTitle = LocalizationKey(key: "adyen.card.numberItem.title")
    /// 1234 5678 9012 3456
    package static let cardNumberItemPlaceholder = LocalizationKey(key: "adyen.card.numberItem.placeholder")
    /// Invalid card number
    package static let cardNumberItemInvalid = LocalizationKey(key: "adyen.card.numberItem.invalid")
    /// Expiry date
    package static let cardExpiryItemTitle = LocalizationKey(key: "adyen.card.expiryItem.title")
    /// Expiry date (optional)
    package static let cardExpiryItemTitleOptional = LocalizationKey(key: "adyen.card.expiryItem.title.optional")
    /// MM/YY
    package static let cardExpiryItemPlaceholder = LocalizationKey(key: "adyen.card.expiryItem.placeholder")
    /// Invalid expiry date
    package static let cardExpiryItemInvalid = LocalizationKey(key: "adyen.card.expiryItem.invalid")
    /// Month, 2 digits, Year, 2 digits
    package static let cardExpiryItemAccessibilityLabel = LocalizationKey(key: "adyen.card.expiryItem.accessibilityLabel")
    /// Invalid CVC / CVV format
    package static let cardCvcItemInvalid = LocalizationKey(key: "adyen.card.cvcItem.invalid")
    /// Security code
    package static let cardCvcItemTitle = LocalizationKey(key: "adyen.card.cvcItem.title")
    /// 123
    package static let cardCvcItemPlaceholder = LocalizationKey(key: "adyen.card.cvcItem.placeholder")
    /// Verify your card
    package static let cardStoredTitle = LocalizationKey(key: "adyen.card.stored.title")
    /// Please enter the CVC code for %@
    package static let cardStoredMessage = LocalizationKey(key: "adyen.card.stored.message")
    /// Expires %@
    package static let cardStoredExpires = LocalizationKey(key: "adyen.card.stored.expires")
    /// %@ isn't supported
    package static let cardNumberItemUnsupportedBrand = LocalizationKey(key: "adyen.card.numberItem.unsupportedBrand")
    /// The entered card brand isn't supported
    package static let cardNumberItemUnknownBrand = LocalizationKey(key: "adyen.card.numberItem.unknownBrand")
    /// Scan your card
    package static let cardScanYourCardButton = LocalizationKey(key: "adyen.card.scanYourCardButton")
    /// Card Brand
    package static let creditCardDualBrandTitle = LocalizationKey(key: "adyen.creditCard.dualBrand.title")
    /// Select the card brand you prefer to pay with. This is optional.
    package static let creditCardDualBrandDescription = LocalizationKey(key: "adyen.creditCard.dualBrand.description")
    /// Confirm %@ payment
    package static let dropInStoredTitle = LocalizationKey(key: "adyen.dropIn.stored.title")
    /// Change Payment Method
    package static let dropInPreselectedOpenAllTitle = LocalizationKey(key: "adyen.dropIn.preselected.openAll.title")
    /// Continue to %@
    package static let continueTo = LocalizationKey(key: "adyen.continueTo")
    /// Continue
    package static let continueTitle = LocalizationKey(key: "adyen.continueTitle")
    /// Telephone number
    package static let phoneNumberTitle = LocalizationKey(key: "adyen.phoneNumber.title")
    /// Invalid telephone number
    package static let phoneNumberInvalid = LocalizationKey(key: "adyen.phoneNumber.invalid")
    /// Prefix
    package static let telephonePrefix = LocalizationKey(key: "adyen.telephonePrefix")
    /// 123–456–789
    package static let phoneNumberPlaceholder = LocalizationKey(key: "adyen.phoneNumber.placeholder")
    /// %@ digits
    package static let cardCvcItemPlaceholderDigits = LocalizationKey(key: "adyen.card.cvcItem.placeholder.digits")
    /// Email address
    package static let emailItemTitle = LocalizationKey(key: "adyen.emailItem.title")
    /// Email address
    package static let emailItemPlaceHolder = LocalizationKey(key: "adyen.emailItem.placeHolder")
    /// Invalid email address
    package static let emailItemInvalid = LocalizationKey(key: "adyen.emailItem.invalid")
    /// More options
    package static let moreOptions = LocalizationKey(key: "adyen.moreOptions")
    /// Total
    package static let applePayTotal = LocalizationKey(key: "adyen.applePay.total")
    /// Confirm your payment on the MB WAY app
    package static let mbwayConfirmPayment = LocalizationKey(key: "adyen.mbway.confirmPayment")
    /// Waiting for confirmation
    package static let awaitWaitForConfirmation = LocalizationKey(key: "adyen.await.waitForConfirmation")
    /// Open your banking app to confirm the payment.
    package static let blikConfirmPayment = LocalizationKey(key: "adyen.blik.confirmPayment")
    /// Enter 6 numbers
    package static let blikInvalid = LocalizationKey(key: "adyen.blik.invalid")
    /// 6-digit code
    package static let blikCode = LocalizationKey(key: "adyen.blik.code")
    /// Get the code from your banking app.
    package static let blikHelp = LocalizationKey(key: "adyen.blik.help")
    /// 123–456
    package static let blikPlaceholder = LocalizationKey(key: "adyen.blik.placeholder")
    /// Preauthorize with %@
    package static let preauthorizeWith = LocalizationKey(key: "adyen.preauthorizeWith")
    /// Confirm preauthorization
    package static let confirmPreauthorization = LocalizationKey(key: "adyen.confirmPreauthorization")
    /// Security code (optional)
    package static let cardCvcItemTitleOptional = LocalizationKey(key: "adyen.card.cvcItem.title.optional")
    /// Confirm purchase
    package static let confirmPurchase = LocalizationKey(key: "adyen.confirmPurchase")
    /// Last name
    package static let lastName = LocalizationKey(key: "adyen.lastName")
    /// First name
    package static let firstName = LocalizationKey(key: "adyen.firstName")
    /// Pin
    package static let cardPinTitle = LocalizationKey(key: "adyen.card.pin.title")
    /// Incomplete field
    package static let missingField = LocalizationKey(key: "adyen.missingField")
    /// Redeem
    package static let cardApplyGiftcard = LocalizationKey(key: "adyen.card.applyGiftcard")
    /// Collection Institution Number
    package static let voucherCollectionInstitutionNumber = LocalizationKey(key: "adyen.voucher.collectionInstitutionNumber")
    /// Merchant
    package static let voucherMerchantName = LocalizationKey(key: "adyen.voucher.merchantName")
    /// Expiration Date
    package static let voucherExpirationDate = LocalizationKey(key: "adyen.voucher.expirationDate")
    /// Payment Reference
    package static let voucherPaymentReferenceLabel = LocalizationKey(key: "adyen.voucher.paymentReferenceLabel")
    /// Shopper Name
    package static let voucherShopperName = LocalizationKey(key: "adyen.voucher.shopperName")
    /// Copy
    package static let buttonCopy = LocalizationKey(key: "adyen.button.copy")
    /// Thank you for your purchase, please use the following information to complete your payment.
    package static let voucherIntroduction = LocalizationKey(key: "adyen.voucher.introduction")
    /// Read instructions
    package static let voucherReadInstructions = LocalizationKey(key: "adyen.voucher.readInstructions")
    /// Save as image
    package static let voucherSaveImage = LocalizationKey(key: "adyen.voucher.saveImage")
    /// Finish
    package static let voucherFinish = LocalizationKey(key: "adyen.voucher.finish")
    /// 123.123.123-12
    package static let cardBrazilSSNPlaceholder = LocalizationKey(key: "adyen.card.brazilSSN.placeholder")
    /// Amount
    package static let amount = LocalizationKey(key: "adyen.amount")
    /// Entity
    package static let voucherEntity = LocalizationKey(key: "adyen.voucher.entity")
    /// Use your banking app to scan the QR code or copy the PIX code below to complete your payment.
    package static let pixInstructions = LocalizationKey(key: "adyen.pix.instructions")
    /// You have %@ to pay
    package static let pixExpirationLabel = LocalizationKey(key: "adyen.pix.expirationLabel")
    /// Copy code
    package static let pixCopyButton = LocalizationKey(key: "adyen.pix.copyButton")
    /// Code copied to clipboard
    package static let pixInstructionsCopiedMessage = LocalizationKey(key: "adyen.pix.instructions.copiedMessage")
    /// Copy PIX code
    package static let pixCodeCopyLabel = LocalizationKey(key: "adyen.pix.code.copy.label")
    /// PIX code copied
    package static let pixCodeCopiedLabel = LocalizationKey(key: "adyen.pix.code.copied.label")
    /// Billing address
    package static let billingAddressSectionTitle = LocalizationKey(key: "adyen.billingAddressSection.title")
    /// Your billing address
    package static let billingAddressPlaceholder = LocalizationKey(key: "adyen.billingAddress.placeholder")
    /// Delivery Address
    package static let deliveryAddressSectionTitle = LocalizationKey(key: "adyen.deliveryAddressSection.title")
    /// Your delivery address
    package static let deliveryAddressPlaceholder = LocalizationKey(key: "adyen.deliveryAddress.placeholder")
    /// Country/Region
    package static let countryFieldTitle = LocalizationKey(key: "adyen.countryField.title")
    /// Country/Region
    package static let countryFieldPlaceholder = LocalizationKey(key: "adyen.countryField.placeholder")
    /// Invalid country/region
    package static let countryFieldInvalid = LocalizationKey(key: "adyen.countryField.invalid")
    /// Address
    package static let addressFieldTitle = LocalizationKey(key: "adyen.addressField.title")
    /// Address
    package static let addressFieldPlaceholder = LocalizationKey(key: "adyen.addressField.placeholder")
    /// Street
    package static let streetFieldTitle = LocalizationKey(key: "adyen.streetField.title")
    /// Street
    package static let streetFieldPlaceholder = LocalizationKey(key: "adyen.streetField.placeholder")
    /// House number
    package static let houseNumberFieldTitle = LocalizationKey(key: "adyen.houseNumberField.title")
    /// House number
    package static let houseNumberFieldPlaceholder = LocalizationKey(key: "adyen.houseNumberField.placeholder")
    /// City
    package static let cityFieldTitle = LocalizationKey(key: "adyen.cityField.title")
    /// City
    package static let cityFieldPlaceholder = LocalizationKey(key: "adyen.cityField.placeholder")
    /// City / Town
    package static let cityTownFieldTitle = LocalizationKey(key: "adyen.cityTownField.title")
    /// City / Town
    package static let cityTownFieldPlaceholder = LocalizationKey(key: "adyen.cityTownField.placeholder")
    /// Postal code
    package static let postalCodeFieldTitle = LocalizationKey(key: "adyen.postalCodeField.title")
    /// Postal code
    package static let postalCodeFieldPlaceholder = LocalizationKey(key: "adyen.postalCodeField.placeholder")
    /// Zip code
    package static let zipCodeFieldTitle = LocalizationKey(key: "adyen.zipCodeField.title")
    /// Zip code
    package static let zipCodeFieldPlaceholder = LocalizationKey(key: "adyen.zipCodeField.placeholder")
    /// State
    package static let stateFieldTitle = LocalizationKey(key: "adyen.stateField.title")
    /// State
    package static let stateFieldPlaceholder = LocalizationKey(key: "adyen.stateField.placeholder")
    /// Select state
    package static let selectStateFieldPlaceholder = LocalizationKey(key: "adyen.selectStateField.placeholder")
    /// State or province
    package static let stateOrProvinceFieldTitle = LocalizationKey(key: "adyen.stateOrProvinceField.title")
    /// State or province
    package static let stateOrProvinceFieldPlaceholder = LocalizationKey(key: "adyen.stateOrProvinceField.placeholder")
    /// Select province or territory
    package static let selectStateOrProvinceFieldPlaceholder = LocalizationKey(key: "adyen.selectStateOrProvinceField.placeholder")
    /// Province or Territory
    package static let provinceOrTerritoryFieldTitle = LocalizationKey(key: "adyen.provinceOrTerritoryField.title")
    /// Province or Territory
    package static let provinceOrTerritoryFieldPlaceholder = LocalizationKey(key: "adyen.provinceOrTerritoryField.placeholder")
    /// Apartment / Suite
    package static let apartmentSuiteFieldTitle = LocalizationKey(key: "adyen.apartmentSuiteField.title")
    /// Apartment / Suite
    package static let apartmentSuiteFieldPlaceholder = LocalizationKey(key: "adyen.apartmentSuiteField.placeholder")
    /// Required field, please fill it in.
    package static let errorFeedbackEmptyField = LocalizationKey(key: "adyen.errorFeedback.emptyField")
    /// Input format is not valid.
    package static let errorFeedbackIncorrectFormat = LocalizationKey(key: "adyen.errorFeedback.incorrectFormat")
    /// (optional)
    package static let fieldTitleOptional = LocalizationKey(key: "adyen.field.title.optional")
    /// Generate Boleto
    package static let boletobancarioBtnLabel = LocalizationKey(key: "adyen.boletobancario.btnLabel")
    /// Send a copy to my email
    package static let boletoSendCopyToEmail = LocalizationKey(key: "adyen.boleto.sendCopyToEmail")
    /// Personal details
    package static let boletoPersonalDetails = LocalizationKey(key: "adyen.boleto.personalDetails")
    /// CPF/CNPJ
    package static let boletoSocialSecurityNumber = LocalizationKey(key: "adyen.boleto.socialSecurityNumber")
    /// Download PDF
    package static let boletoDownloadPdf = LocalizationKey(key: "adyen.boleto.download.pdf")
    /// Gift cards are only valid in the currency they were issued in
    package static let giftcardCurrencyError = LocalizationKey(key: "adyen.giftcard.currencyError")
    /// This gift card has zero balance
    package static let giftcardNoBalance = LocalizationKey(key: "adyen.giftcard.noBalance")
    /// Confirm card removal
    package static let giftcardRemoveTitle = LocalizationKey(key: "adyen.giftcard.remove.title")
    /// Remove added giftcards?
    package static let giftcardRemoveMessage = LocalizationKey(key: "adyen.giftcard.remove.message")
    /// Added giftcard
    package static let giftcardPaymentMethodTitle = LocalizationKey(key: "adyen.giftcard.paymentMethod.title")
    /// Remaining balance will be %@
    package static let partialPaymentRemainingBalance = LocalizationKey(key: "adyen.partialPayment.remainingBalance")
    /// Select payment method for the remaining %@
    package static let partialPaymentPayRemainingAmount = LocalizationKey(key: "adyen.partialPayment.payRemainingAmount")
    /// Cardholder birthdate (YYMMDD) or Corporate registration number (10 digits)
    package static let cardTaxNumberLabel = LocalizationKey(key: "adyen.card.taxNumber.label")
    /// YYMMDD / 0123456789
    package static let cardTaxNumberPlaceholder = LocalizationKey(key: "adyen.card.taxNumber.placeholder")
    /// Invalid Cardholder birthdate or Corporate registration number
    package static let cardTaxNumberInvalid = LocalizationKey(key: "adyen.card.taxNumber.invalid")
    /// First 2 digits of card password
    package static let cardEncryptedPasswordLabel = LocalizationKey(key: "adyen.card.encryptedPassword.label")
    /// 12
    package static let cardEncryptedPasswordPlaceholder = LocalizationKey(key: "adyen.card.encryptedPassword.placeholder")
    /// Invalid password
    package static let cardEncryptedPasswordInvalid = LocalizationKey(key: "adyen.card.encryptedPassword.invalid")
    /// Birthdate or Corporate registration number
    package static let cardTaxNumberLabelShort = LocalizationKey(key: "adyen.card.taxNumber.label.short")
    /// Separate delivery address
    package static let affirmDeliveryAddressToggleTitle = LocalizationKey(key: "adyen.affirm.deliveryAddressToggle.title")
    /// Shopper Reference
    package static let voucherShopperReference = LocalizationKey(key: "adyen.voucher.shopperReference")
    /// Alternative Reference
    package static let voucherAlternativeReference = LocalizationKey(key: "adyen.voucher.alternativeReference")
    /// Number of installments
    package static let cardInstallmentsNumberOfInstallments = LocalizationKey(key: "adyen.card.installments.numberOfInstallments")
    /// One time payment
    package static let cardInstallmentsOneTime = LocalizationKey(key: "adyen.card.installments.oneTime")
    /// Installments payment
    package static let cardInstallmentsTitle = LocalizationKey(key: "adyen.card.installments.title")
    /// Revolving payment
    package static let cardInstallmentsRevolving = LocalizationKey(key: "adyen.card.installments.revolving")
    /// %@x %@
    package static let cardInstallmentsMonthsAndPrice = LocalizationKey(key: "adyen.card.installments.monthsAndPrice")
    /// %@ months
    package static let cardInstallmentsMonths = LocalizationKey(key: "adyen.card.installments.months")
    /// Method of payment
    package static let cardInstallmentsPlan = LocalizationKey(key: "adyen.card.installments.plan")
    /// Bank account holder name
    package static let bacsHolderNameFieldTitle = LocalizationKey(key: "adyen.bacs.holderNameField.title")
    /// Bank account number
    package static let bacsBankAccountNumberFieldTitle = LocalizationKey(key: "adyen.bacs.bankAccountNumberField.title")
    /// Sort code
    package static let bacsBankLocationIdFieldTitle = LocalizationKey(key: "adyen.bacs.bankLocationIdField.title")
    /// I confirm the account is in my name and I am the only signatory required to authorise the Direct Debit on this account.
    package static let bacsLegalConsentToggleTitle = LocalizationKey(key: "adyen.bacs.legalConsentToggle.title")
    /// I agree that the above amount will be deducted from my bank account.
    package static let bacsAmountConsentToggleTitle = LocalizationKey(key: "adyen.bacs.amountConsentToggle.title")
    /// I agree that %@ will be deducted from my bank account.
    package static let bacsSpecifiedAmountConsentToggleTitle = LocalizationKey(key: "adyen.bacs.specifiedAmountConsentToggle.title")
    /// Invalid bank account holder name
    package static let bacsHolderNameFieldInvalidMessage = LocalizationKey(key: "adyen.bacs.holderNameField.invalidMessage")
    /// Invalid bank account number
    package static let bacsBankAccountNumberFieldInvalidMessage = LocalizationKey(key: "adyen.bacs.bankAccountNumberField.invalidMessage")
    /// Invalid sort code
    package static let bacsBankLocationIdFieldInvalidMessage = LocalizationKey(key: "adyen.bacs.bankLocationIdField.invalidMessage")
    /// Confirm and pay
    package static let bacsPaymentButtonTitle = LocalizationKey(key: "adyen.bacs.paymentButton.title")
    /// Download your Direct Debit Instruction (DDI / Mandate)
    package static let bacsDownloadMandate = LocalizationKey(key: "adyen.bacs.downloadMandate")
    /// Bank account
    package static let achBankAccountTitle = LocalizationKey(key: "adyen.ach.bankAccount.title")
    /// Account holder name
    package static let achAccountHolderNameFieldTitle = LocalizationKey(key: "adyen.ach.accountHolderNameField.title")
    /// Invalid account holder name
    package static let achAccountHolderNameFieldInvalid = LocalizationKey(key: "adyen.ach.accountHolderNameField.invalid")
    /// Account number
    package static let achAccountNumberFieldTitle = LocalizationKey(key: "adyen.ach.accountNumberField.title")
    /// Invalid account number
    package static let achAccountNumberFieldInvalid = LocalizationKey(key: "adyen.ach.accountNumberField.invalid")
    /// ABA routing number
    package static let achAccountLocationFieldTitle = LocalizationKey(key: "adyen.ach.accountLocationField.title")
    /// Invalid ABA routing number
    package static let achAccountLocationFieldInvalid = LocalizationKey(key: "adyen.ach.accountLocationField.invalid")
    /// Bank
    package static let selectFieldTitle = LocalizationKey(key: "idealIssuer.selectField.title")
    /// By continuing you agree with the #terms and conditions#
    package static let onlineBankingTermsAndConditions = LocalizationKey(key: "adyen.onlineBanking.termsAndConditions")
    /// Take a screenshot or save the QR code, open your banking application and upload the QR code to verify the details and complete the payment.
    package static let qrCodeInstructionMessage = LocalizationKey(key: "adyen.qrCode.instructionMessage")
    /// This QR code is valid for %@
    package static let qrCodeTimerExpirationMessage = LocalizationKey(key: "adyen.qrCode.timerExpirationMessage")
    /// No banks found with your search query…
    package static let paybybankSubtitle = LocalizationKey(key: "adyen.paybybank.subtitle")
    /// No results for
    package static let paybybankTitle = LocalizationKey(key: "adyen.paybybank.title")
    /// Search…
    package static let searchPlaceholder = LocalizationKey(key: "adyen.search.placeholder")
    /// Use Pay by Bank to pay instantly from any bank account.
    package static let payByBankAISDDDisclaimerHeader = LocalizationKey(key: "adyen.payByBankAISDD.disclaimer.header")
    /// By connecting your bank account you are authorizing debits to your account for any amount owed for use of our services and/or purchase of our products, until this authorization is revoked.
    package static let payByBankAISDDDisclaimerBody = LocalizationKey(key: "adyen.payByBankAISDD.disclaimer.body")
    /// Continue to Pay by Bank
    package static let payByBankAISDDSubmit = LocalizationKey(key: "adyen.payByBankAISDD.submit")
    /// + more
    package static let payByBankAISDDMore = LocalizationKey(key: "adyen.payByBankAISDD.more")
    /// How would you like to use UPI?
    package static let upiModeSelection = LocalizationKey(key: "adyen.upi.modeSelection")
    /// UPI app
    package static let upiModePayByAnyUpi = LocalizationKey(key: "adyen.upi.mode.payByAnyUpi")
    /// Select your preferred UPI app
    package static let upiIntentInstruction = LocalizationKey(key: "adyen.upi.intent.instruction")
    /// Select your preferred UPI app to continue
    package static let upiErrorNoAppSelected = LocalizationKey(key: "adyen.upi.error.noAppSelected")
    /// UPI ID
    package static let upiCollectFieldLabel = LocalizationKey(key: "adyen.upi.collect.field.label")
    /// Enter your UPI ID
    package static let upiCollectInstruction = LocalizationKey(key: "adyen.upi.collect.instruction")
    /// UPI ID
    package static let upiModeEnterUpiId = LocalizationKey(key: "adyen.upi.mode.enterUpiId")
    /// Enter a valid UPI
    package static let upiCollectFieldInvalidIdError = LocalizationKey(key: "adyen.upi.collect.field.invalidIdError")
    /// Awaiting your confirmation…
    package static let upiCollectConfirmPayment = LocalizationKey(key: "adyen.upi.collect.confirmPayment")
    /// Open your UPI app to confirm the payment
    package static let upiVpaWaitingMessage = LocalizationKey(key: "adyen.upi.vpaWaitingMessage")
    /// You have %@ to approve
    package static let upiQrcodeTimerMessage = LocalizationKey(key: "adyen.upi.qrcode.timerMessage")
    /// Take a screenshot to upload in the UPI app or scan the QR code using your preferred UPI app to complete the payment.
    package static let upiQrcodeInstructions = LocalizationKey(key: "adyen.upi.qrcode.instructions")
    /// Cash App Pay
    package static let cashAppPayTitle = LocalizationKey(key: "adyen.cashAppPay.title")
    /// Cashtag
    package static let cashAppPayCashtag = LocalizationKey(key: "adyen.cashAppPay.cashtag")
    /// No or an outdated version of TWINT is installed on this device. Please update or install the TWINT app.
    package static let twintNoAppsInstalledMessage = LocalizationKey(key: "adyen.twint.noAppsInstalled.message")
    /// Secure checkout
    package static let threeds2DARegistrationTitle = LocalizationKey(key: "adyen.threeds2.DA.registration.title")
    /// biometric
    package static let threeds2DABiometrics = LocalizationKey(key: "adyen.threeds2.DA.biometrics")
    /// Face ID
    package static let threeds2DAFaceID = LocalizationKey(key: "adyen.threeds2.DA.faceID")
    /// Touch ID
    package static let threeds2DATouchID = LocalizationKey(key: "adyen.threeds2.DA.touchID")
    /// Optic ID
    package static let threeds2DAOpticID = LocalizationKey(key: "adyen.threeds2.DA.opticID")
    /// Check out faster next time with this card
    package static let threeds2DARegistrationDescription = LocalizationKey(key: "adyen.threeds2.DA.registration.description")
    /// Skip manual entry & speed up checkout
    package static let threeds2DARegistrationFirstInfo = LocalizationKey(key: "adyen.threeds2.DA.registration.firstInfo")
    /// Pay with %@ or passcode
    package static let threeds2DARegistrationSecondInfo = LocalizationKey(key: "adyen.threeds2.DA.registration.secondInfo")
    /// Edit or remove your details at any time
    package static let threeds2DARegistrationThirdInfo = LocalizationKey(key: "adyen.threeds2.DA.registration.thirdInfo")
    /// Use secure checkout
    package static let threeds2DARegistrationPositiveButton = LocalizationKey(key: "adyen.threeds2.DA.registration.positiveButton")
    /// Not now
    package static let threeds2DARegistrationNegativeButton = LocalizationKey(key: "adyen.threeds2.DA.registration.negativeButton")
    /// Approve transaction
    package static let threeds2DAApprovalTitle = LocalizationKey(key: "adyen.threeds2.DA.approval.title")
    /// Approve this transaction to complete your purchase.
    package static let threeds2DAApprovalDescription = LocalizationKey(key: "adyen.threeds2.DA.approval.description")
    /// Approve transaction
    package static let threeds2DAApprovalPositiveButton = LocalizationKey(key: "adyen.threeds2.DA.approval.positiveButton")
    /// Other options
    package static let threeds2DAApprovalNegativeButton = LocalizationKey(key: "adyen.threeds2.DA.approval.negativeButton")
    /// Other options
    package static let threeds2DAApprovalActionSheetTitle = LocalizationKey(key: "adyen.threeds2.DA.approval.actionSheet.title")
    /// Approve differently
    package static let threeds2DAApprovalActionSheetFallback = LocalizationKey(key: "adyen.threeds2.DA.approval.actionSheet.fallback")
    /// Remove my credentials
    package static let threeds2DAApprovalActionSheetRemove = LocalizationKey(key: "adyen.threeds2.DA.approval.actionSheet.remove")
    /// Remove credentials
    package static let threeds2DAApprovalRemoveAlertTitle = LocalizationKey(key: "adyen.threeds2.DA.approval.remove.alert.title")
    /// Are you sure you want to remove your Secure Checkout credentials?
    package static let threeds2DAApprovalRemoveAlertDescription = LocalizationKey(key: "adyen.threeds2.DA.approval.remove.alert.description")
    /// Remove
    package static let threeds2DAApprovalRemoveAlertPositiveButton = LocalizationKey(key: "adyen.threeds2.DA.approval.remove.alert.positiveButton")
    /// Cancel
    package static let threeds2DAApprovalRemoveAlertNegativeButton = LocalizationKey(key: "adyen.threeds2.DA.approval.remove.alert.negativeButton")
    /// Troubleshooting
    package static let threeds2DAErrorTroubleshootingTitle = LocalizationKey(key: "adyen.threeds2.DA.error.troubleshootingTitle")
    /// Ongoing payment issues may be resolved by resetting your Secure Checkout details.
    package static let threeds2DAErrorTroubleshootingDescription = LocalizationKey(key: "adyen.threeds2.DA.error.troubleshootingDescription")
    /// Reset Secure Checkout
    package static let threeds2DAErrorTroubleshootingButtonTitle = LocalizationKey(key: "adyen.threeds2.DA.error.troubleshootingButtonTitle")
    /// Reset Secure Checkout
    package static let threeds2DAErrorResetAlertTitle = LocalizationKey(key: "adyen.threeds2.DA.error.reset.alert.title")
    /// You will be redirected to complete this payment in a different way.
    package static let threeds2DAErrorResetAlertDescription = LocalizationKey(key: "adyen.threeds2.DA.error.reset.alert.description")
    /// Reset
    package static let threeds2DAErrorResetAlertPositiveButton = LocalizationKey(key: "adyen.threeds2.DA.error.reset.alert.positiveButton")
    /// Cancel
    package static let threeds2DAErrorResetAlertNegativeButton = LocalizationKey(key: "adyen.threeds2.DA.error.reset.alert.negativeButton")
    /// Authenticating…
    package static let threeds2DAApprovalErrorTitle = LocalizationKey(key: "adyen.threeds2.DA.approval.error.title")
    /// Couldn’t approve payment with Secure Checkout
    package static let threeds2DAApprovalErrorMessage = LocalizationKey(key: "adyen.threeds2.DA.approval.error.message")
    /// Approve differently
    package static let threeds2DAApprovalErrorButtonTitle = LocalizationKey(key: "adyen.threeds2.DA.approval.error.buttonTitle")
    /// Let’s try next time!
    package static let threeds2DARegistrationErrorTitle = LocalizationKey(key: "adyen.threeds2.DA.registration.error.title")
    /// Your payment has still been authenticated successfully but the Secure Checkout service was unavailable.
    package static let threeds2DARegistrationErrorMessage = LocalizationKey(key: "adyen.threeds2.DA.registration.error.message")
    /// Finish
    package static let threeds2DARegistrationErrorButtonTitle = LocalizationKey(key: "adyen.threeds2.DA.registration.error.buttonTitle")
    /// Credentials removed
    package static let threeds2DADeletionConfirmationTitle = LocalizationKey(key: "adyen.threeds2.DA.deletion.confirmation.title")
    /// You will no longer be asked to approve transactions through Secure Checkout.
    package static let threeds2DADeletionConfirmationMessage = LocalizationKey(key: "adyen.threeds2.DA.deletion.confirmation.message")
    /// Continue
    package static let threeds2DADeletionConfirmationButtonTitle = LocalizationKey(key: "adyen.threeds2.DA.deletion.confirmation.buttonTitle")
    /// No results found
    package static let pickerSearchEmptyTitle = LocalizationKey(key: "adyen.picker.search.empty.title")
    /// '%@' did not match with anything
    package static let pickerSearchEmptySubtitle = LocalizationKey(key: "adyen.picker.search.empty.subtitle")
    /// Search for your address
    package static let addressLookupSearchPlaceholder = LocalizationKey(key: "adyen.address.lookup.search.placeholder")
    /// Can't search for your address?
    package static let addressLookupSearchEmptyTitle = LocalizationKey(key: "adyen.address.lookup.search.empty.title")
    /// You can always #enter your address manually#
    package static let addressLookupSearchEmptySubtitle = LocalizationKey(key: "adyen.address.lookup.search.empty.subtitle")
    /// No results found
    package static let addressLookupSearchEmptyTitleNoResults = LocalizationKey(key: "adyen.address.lookup.search.empty.title.noResults")
    /// '%@' did not match with anything, try again or use #manual address entry#
    package static let addressLookupSearchEmptySubtitleNoResults = LocalizationKey(key: "adyen.address.lookup.search.empty.subtitle.noResults")
    /// Address required
    package static let addressLookupItemValidationFailureMessageEmpty = LocalizationKey(key: "adyen.address.lookup.item.validationFailureMessage.empty")
    /// Invalid Address
    package static let addressLookupItemValidationFailureMessageInvalid = LocalizationKey(key: "adyen.address.lookup.item.validationFailureMessage.invalid")
    /// Enter address manually
    package static let addressLookupSearchManualEntryItemTitle = LocalizationKey(key: "adyen.address.lookup.search.manualEntryItem.title")
    /// Last 4 digits
    package static let accessibilityLastFourDigits = LocalizationKey(key: "adyen.accessibility.lastFourDigits")
    /// How would you like to use PayTo?
    package static let paytoModeSelection = LocalizationKey(key: "adyen.payto.mode.selection")
    /// Mobile number
    package static let mobileNumber = LocalizationKey(key: "adyen.mobileNumber")
    /// Mobile
    package static let paytoPayidOptionPhone = LocalizationKey(key: "adyen.payto.payid.option.phone")
    /// Account holder first name
    package static let paytoLabelFirstName = LocalizationKey(key: "adyen.payto.label.firstName")
    /// Account holder last name
    package static let paytoLabelLastName = LocalizationKey(key: "adyen.payto.label.lastName")
    /// Identifier
    package static let paytoPayidLabelIdentifier = LocalizationKey(key: "adyen.payto.payid.label.identifier")
    /// Australian Business Number
    package static let paytoPayidAbnHint = LocalizationKey(key: "adyen.payto.payid.abn.hint")
    /// Organization ID
    package static let paytoPayidLabelOrgid = LocalizationKey(key: "adyen.payto.payid.label.orgid")
    /// Organization ID number
    package static let paytoPayidOrgidHint = LocalizationKey(key: "adyen.payto.payid.orgid.hint")
    /// Bank account number
    package static let paytoBsbLabelBankAccountNumber = LocalizationKey(key: "adyen.payto.bsb.label.bankAccountNumber")
    /// Bank state branch
    package static let paytoBsbBankStateBranchHint = LocalizationKey(key: "adyen.payto.bsb.bankStateBranch.hint")
    /// Enter the bank account number and the Bank State Branch that is connected to your account to continue
    package static let paytoBsbDescription = LocalizationKey(key: "adyen.payto.bsb.description")
    /// Mobile phone
    package static let paytoPayidPhoneHint = LocalizationKey(key: "adyen.payto.payid.phone.hint")
    /// Email
    package static let paytoPayidOptionEmail = LocalizationKey(key: "adyen.payto.payid.option.email")
    /// Enter a correct first name
    package static let paytoFirstNameInvalid = LocalizationKey(key: "adyen.payto.firstName.invalid")
    /// Enter a correct last name
    package static let paytoLastNameInvalid = LocalizationKey(key: "adyen.payto.lastName.invalid")
    /// Enter a correct Australian Business Number
    package static let paytoPayidAbnInvalid = LocalizationKey(key: "adyen.payto.payid.abn.invalid")
    /// Enter a correct organization ID number
    package static let paytoPayidOrgidInvalid = LocalizationKey(key: "adyen.payto.payid.orgid.invalid")
    /// Enter a correct email address
    package static let paytoPayidEmailInvalid = LocalizationKey(key: "adyen.payto.payid.email.invalid")
    /// Enter a correct Bank State Branch
    package static let paytoBsbBankStateBranchInvalid = LocalizationKey(key: "adyen.payto.bsb.bankStateBranch.invalid")
    /// Enter a correct bank account number
    package static let paytoBsbBankAccountNumberInvalid = LocalizationKey(key: "adyen.payto.bsb.bankAccountNumber.invalid")
    /// Enter the PayID and account details that are connected to your PayTo account.
    package static let paytoPayidDescription = LocalizationKey(key: "adyen.payto.payid.description")
    /// Thank you for your purchase, complete your payment by logging into you bank account, authorize the PayTo agreement and approve the payment terms.
    package static let paytoAwaitDescription = LocalizationKey(key: "adyen.payto.await.description")
    /// Allow camera access
    package static let cardScannerCameraAccessDeniedAlertTitle = LocalizationKey(key: "adyen.card.scanner.camera.access.denied.alert.title")
    /// Access was previously denied. To scan cards, please grant access from Settings.
    package static let cardScannerCameraAccessDeniedAlertMessage = LocalizationKey(key: "adyen.card.scanner.camera.access.denied.alert.message")
    /// Open Settings
    package static let cardScannerCameraAccessDeniedAlertSettingsButtonTitle = LocalizationKey(key: "adyen.card.scanner.camera.access.denied.alert.settingsButton.title")
    
    internal let key: String
    
    /// :nodoc:
    package init(key: String) {
        self.key = key
    }

}

// swiftlint:enable all
