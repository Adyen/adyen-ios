//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// swiftlint:disable all
@_spi(AdyenInternal)
public struct LocalizationKey {

    /// Pay
    public static let submitButton = LocalizationKey(key: "adyen.submitButton")
    /// Pay %@
    public static let submitButtonFormatted = LocalizationKey(key: "adyen.submitButton.formatted")
    /// Cancel
    public static let cancelButton = LocalizationKey(key: "adyen.cancelButton")
    /// OK
    public static let dismissButton = LocalizationKey(key: "adyen.dismissButton")
    /// Remove
    public static let removeButton = LocalizationKey(key: "adyen.removeButton")
    /// Error
    public static let errorTitle = LocalizationKey(key: "adyen.error.title")
    /// An unknown error occurred
    public static let errorUnknown = LocalizationKey(key: "adyen.error.unknown")
    /// Invalid Input
    public static let validationAlertTitle = LocalizationKey(key: "adyen.validationAlert.title")
    /// Others
    public static let paymentMethodsOtherMethods = LocalizationKey(key: "adyen.paymentMethods.otherMethods")
    /// Stored
    public static let paymentMethodsStoredMethods = LocalizationKey(key: "adyen.paymentMethods.storedMethods")
    /// Applied
    public static let paymentMethodsPaidMethods = LocalizationKey(key: "adyen.paymentMethods.paidMethods")
    /// Payment Methods
    public static let paymentMethodsTitle = LocalizationKey(key: "adyen.paymentMethods.title")
    /// Yes, remove
    public static let paymentMethodRemoveButton = LocalizationKey(key: "adyen.paymentMethod.removeButton")
    /// The payment was refused. Please try again.
    public static let paymentRefusedMessage = LocalizationKey(key: "adyen.payment.refused.message")
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
    /// Enter name as shown on card
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
    /// Security code
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
    /// Prefix
    public static let telephonePrefix = LocalizationKey(key: "adyen.telephonePrefix")
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
    /// Total
    public static let applePayTotal = LocalizationKey(key: "adyen.applePay.total")
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
    /// Security code (optional)
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
    /// Your billing address
    public static let billingAddressPlaceholder = LocalizationKey(key: "adyen.billingAddress.placeholder")
    /// Delivery Address
    public static let deliveryAddressSectionTitle = LocalizationKey(key: "adyen.deliveryAddressSection.title")
    /// Your delivery address
    public static let deliveryAddressPlaceholder = LocalizationKey(key: "adyen.deliveryAddress.placeholder")
    /// Country/Region
    public static let countryFieldTitle = LocalizationKey(key: "adyen.countryField.title")
    /// Country/Region
    public static let countryFieldPlaceholder = LocalizationKey(key: "adyen.countryField.placeholder")
    /// Invalid country/region
    public static let countryFieldInvalid = LocalizationKey(key: "adyen.countryField.invalid")
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
    /// Confirm card removal
    public static let giftcardRemoveTitle = LocalizationKey(key: "adyen.giftcard.remove.title")
    /// Remove added giftcards?
    public static let giftcardRemoveMessage = LocalizationKey(key: "adyen.giftcard.remove.message")
    /// Added giftcard
    public static let giftcardPaymentMethodTitle = LocalizationKey(key: "adyen.giftcard.paymentMethod.title")
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
    /// Bank
    public static let selectFieldTitle = LocalizationKey(key: "idealIssuer.selectField.title")
    /// By continuing you agree with the #terms and conditions#
    public static let onlineBankingTermsAndConditions = LocalizationKey(key: "adyen.onlineBanking.termsAndConditions")
    /// Take a screenshot or save the QR code, open your banking application and upload the QR code to verify the details and complete the payment.
    public static let qrCodeInstructionMessage = LocalizationKey(key: "adyen.qrCode.instructionMessage")
    /// This QR code is valid for %@
    public static let qrCodeTimerExpirationMessage = LocalizationKey(key: "adyen.qrCode.timerExpirationMessage")
    /// No banks found with your search query…
    public static let paybybankSubtitle = LocalizationKey(key: "adyen.paybybank.subtitle")
    /// No results for
    public static let paybybankTitle = LocalizationKey(key: "adyen.paybybank.title")
    /// Search…
    public static let searchPlaceholder = LocalizationKey(key: "adyen.search.placeholder")
    /// How would you like to use UPI?
    public static let upiModeSelection = LocalizationKey(key: "adyen.upi.modeSelection")
    /// Enter a correct virtual payment address
    public static let UPIVpaValidationMessage = LocalizationKey(key: "adyen.UPIVpa.validationMessage")
    /// Generate the QR code that you can download or screenshot and upload it into the UPI app to complete the payment.
    public static let UPIQrcodeGenerationMessage = LocalizationKey(key: "adyen.UPIQrcode.generationMessage")
    /// You have %@ to approve
    public static let UPIQrcodeTimerMessage = LocalizationKey(key: "adyen.UPIQrcode.timerMessage")
    /// Awaiting your confirmation…
    public static let upiCollectConfirmPayment = LocalizationKey(key: "adyen.upiCollect.confirmPayment")
    /// Open your UPI app to confirm the payment
    public static let upiVpaWaitingMessage = LocalizationKey(key: "adyen.upi.vpaWaitingMessage")
    /// Generate QR code
    public static let QRCodeGenerateQRCode = LocalizationKey(key: "adyen.QRCode.generateQRCode")
    /// Take a screenshot to upload in the UPI app or scan the QR code using your preferred UPI app to complete the payment.
    public static let UPIQRCodeInstructions = LocalizationKey(key: "adyen.UPI.QRCodeInstructions")
    /// Pay by any UPI app
    public static let UPIFirstTabTitle = LocalizationKey(key: "adyen.UPI.firstTabTitle")
    /// Other UPI options
    public static let UPISecondTabTitle = LocalizationKey(key: "adyen.UPI.secondTabTitle")
    /// Enter UPI ID
    public static let UPICollectDropdownLabel = LocalizationKey(key: "adyen.UPI.collectDropdownLabel")
    /// Enter UPI ID / VPA
    public static let UPICollectFieldLabel = LocalizationKey(key: "adyen.UPI.collectFieldLabel")
    /// Select a payment method to continue
    public static let UPIErrorNoAppSelected = LocalizationKey(key: "adyen.UPI.error.noAppSelected")
    /// Cash App Pay
    public static let cashAppPayTitle = LocalizationKey(key: "adyen.cashAppPay.title")
    /// Cashtag
    public static let cashAppPayCashtag = LocalizationKey(key: "adyen.cashAppPay.cashtag")
    /// No or an outdated version of TWINT is installed on this device. Please update or install the TWINT app.
    public static let twintNoAppsInstalledMessage = LocalizationKey(key: "adyen.twint.noAppsInstalled.message")
    /// Secure checkout
    public static let threeds2DARegistrationTitle = LocalizationKey(key: "adyen.threeds2.DA.registration.title")
    /// biometric
    public static let threeds2DABiometrics = LocalizationKey(key: "adyen.threeds2.DA.biometrics")
    /// FaceID
    public static let threeds2DAFaceID = LocalizationKey(key: "adyen.threeds2.DA.faceID")
    /// TouchID
    public static let threeds2DATouchID = LocalizationKey(key: "adyen.threeds2.DA.touchID")
    /// OpticID
    public static let threeds2DAOpticID = LocalizationKey(key: "adyen.threeds2.DA.opticID")
    /// Check out faster next time with this card
    public static let threeds2DARegistrationDescription = LocalizationKey(key: "adyen.threeds2.DA.registration.description")
    /// Skip manual entry & speed up checkout
    public static let threeds2DARegistrationFirstInfo = LocalizationKey(key: "adyen.threeds2.DA.registration.firstInfo")
    /// Pay with Face ID or passcode
    public static let threeds2DARegistrationSecondInfo = LocalizationKey(key: "adyen.threeds2.DA.registration.secondInfo")
    /// Edit or remove your details at any time.
    public static let threeds2DARegistrationThirdInfo = LocalizationKey(key: "adyen.threeds2.DA.registration.thirdInfo")
    /// Use secure checkout
    public static let threeds2DARegistrationPositiveButton = LocalizationKey(key: "adyen.threeds2.DA.registration.positiveButton")
    /// Not now
    public static let threeds2DARegistrationNegativeButton = LocalizationKey(key: "adyen.threeds2.DA.registration.negativeButton")
    /// Approve transaction
    public static let threeds2DAApprovalTitle = LocalizationKey(key: "adyen.threeds2.DA.approval.title")
    /// Approve this transaction to complete your purchase.
    public static let threeds2DAApprovalDescription = LocalizationKey(key: "adyen.threeds2.DA.approval.description")
    /// Approve transaction
    public static let threeds2DAApprovalPositiveButton = LocalizationKey(key: "adyen.threeds2.DA.approval.positiveButton")
    /// Other options
    public static let threeds2DAApprovalNegativeButton = LocalizationKey(key: "adyen.threeds2.DA.approval.negativeButton")
    /// Other options
    public static let threeds2DAApprovalActionSheetTitle = LocalizationKey(key: "adyen.threeds2.DA.approval.actionSheet.title")
    /// Approve differently
    public static let threeds2DAApprovalActionSheetFallback = LocalizationKey(key: "adyen.threeds2.DA.approval.actionSheet.fallback")
    /// Remove my credentials
    public static let threeds2DAApprovalActionSheetRemove = LocalizationKey(key: "adyen.threeds2.DA.approval.actionSheet.remove")
    /// Remove credentials
    public static let threeds2DAApprovalRemoveAlertTitle = LocalizationKey(key: "adyen.threeds2.DA.approval.remove.alert.title")
    /// Are you sure you want to remove your Secure Checkout credentials?
    public static let threeds2DAApprovalRemoveAlertDescription = LocalizationKey(key: "adyen.threeds2.DA.approval.remove.alert.description")
    /// Remove
    public static let threeds2DAApprovalRemoveAlertPositiveButton = LocalizationKey(key: "adyen.threeds2.DA.approval.remove.alert.positiveButton")
    /// Cancel
    public static let threeds2DAApprovalRemoveAlertNegativeButton = LocalizationKey(key: "adyen.threeds2.DA.approval.remove.alert.negativeButton")
    /// Authenticating…
    public static let threeds2DAApprovalErrorTitle = LocalizationKey(key: "adyen.threeds2.DA.approval.error.title")
    /// Couldn’t approve payment with Secure Checkout
    public static let threeds2DAApprovalErrorMessage = LocalizationKey(key: "adyen.threeds2.DA.approval.error.message")
    /// Approve differently
    public static let threeds2DAApprovalErrorButtonTitle = LocalizationKey(key: "adyen.threeds2.DA.approval.error.buttonTitle")
    /// Troubleshooting
    public static let threeds2DAErrorTroubleshootingTitle = LocalizationKey(key: "adyen.threeds2.DA.error.troubleshootingTitle")
    /// Ongoing payment issues may be resolved by resetting your Secure Checkout details.
    public static let threeds2DAErrorTroubleshootingDescription = LocalizationKey(key: "adyen.threeds2.DA.error.troubleshootingDescription")
    /// Reset Secure Checkout
    public static let threeds2DAErrorTroubleshootingButtonTitle = LocalizationKey(key: "adyen.threeds2.DA.error.troubleshootingButtonTitle")
    /// Reset Secure Checkout
    public static let threeds2DAErrorResetAlertTitle = LocalizationKey(key: "adyen.threeds2.DA.error.reset.alert.title")
    /// You will be redirected to complete this payment in a different way
    public static let threeds2DAErrorResetAlertDescription = LocalizationKey(key: "adyen.threeds2.DA.error.reset.alert.description")
    /// Reset
    public static let threeds2DAErrorResetAlertPositiveButton = LocalizationKey(key: "adyen.threeds2.DA.error.reset.alert.positiveButton")
    /// Cancel
    public static let threeds2DAErrorResetAlertNegativeButton = LocalizationKey(key: "adyen.threeds2.DA.error.reset.alert.negativeButton")
    /// Let’s try next time!
    public static let threeds2DARegistrationErrorTitle = LocalizationKey(key: "adyen.threeds2.DA.registration.error.title")
    /// Your payment has still been authenticated successfully but the Secure Checkout service was unavailable.
    public static let threeds2DARegistrationErrorMessage = LocalizationKey(key: "adyen.threeds2.DA.registration.error.message")
    /// Finish
    public static let threeds2DARegistrationErrorButtonTitle = LocalizationKey(key: "adyen.threeds2.DA.registration.error.buttonTitle")
    /// Credentials removed
    public static let threeds2DADeletionConfirmationTitle = LocalizationKey(key: "adyen.threeds2.DA.deletion.confirmation.title")
    /// You will no longer be asked to approve transactions through Secure Checkout.
    public static let threeds2DADeletionConfirmationMessage = LocalizationKey(key: "adyen.threeds2.DA.deletion.confirmation.message")
    /// Continue
    public static let threeds2DADeletionConfirmationButtonTitle = LocalizationKey(key: "adyen.threeds2.DA.deletion.confirmation.buttonTitle")
    /// No results found
    public static let pickerSearchEmptyTitle = LocalizationKey(key: "adyen.picker.search.empty.title")
    /// '%@' did not match with anything
    public static let pickerSearchEmptySubtitle = LocalizationKey(key: "adyen.picker.search.empty.subtitle")
    /// Search for your address
    public static let addressLookupSearchPlaceholder = LocalizationKey(key: "adyen.address.lookup.search.placeholder")
    /// Can't search for your address?
    public static let addressLookupSearchEmptyTitle = LocalizationKey(key: "adyen.address.lookup.search.empty.title")
    /// You can always #enter your address manually#
    public static let addressLookupSearchEmptySubtitle = LocalizationKey(key: "adyen.address.lookup.search.empty.subtitle")
    /// No results found
    public static let addressLookupSearchEmptyTitleNoResults = LocalizationKey(key: "adyen.address.lookup.search.empty.title.noResults")
    /// '%@' did not match with anything, try again or use #manual address entry#
    public static let addressLookupSearchEmptySubtitleNoResults = LocalizationKey(key: "adyen.address.lookup.search.empty.subtitle.noResults")
    /// Address required
    public static let addressLookupItemValidationFailureMessageEmpty = LocalizationKey(key: "adyen.address.lookup.item.validationFailureMessage.empty")
    /// Invalid Address
    public static let addressLookupItemValidationFailureMessageInvalid = LocalizationKey(key: "adyen.address.lookup.item.validationFailureMessage.invalid")
    /// Enter address manually
    public static let addressLookupSearchManualEntryItemTitle = LocalizationKey(key: "adyen.address.lookup.search.manualEntryItem.title")
    /// Last 4 digits
    public static let accessibilityLastFourDigits = LocalizationKey(key: "adyen.accessibility.lastFourDigits")
    
    internal let key: String
    
    /// :nodoc:
    public init(key: String) {
        self.key = key
    }

}

// swiftlint:enable all
