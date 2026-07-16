# API Reference

The Adyen Checkout SDK API Reference.

## Checkout

The entry points for integrating the SDK.

- ``Checkout``
- ``BaseCheckout``
- ``PaymentCheckout``
- ``SessionCheckout``
- ``AdvancedCheckout``
- ``ActionOnlyCheckout``
- ``CheckoutPaymentComponent``

## Configuration

- ``CheckoutConfiguration``
- ``CheckoutConfigurationBuilder``
- ``APIContext``
- ``AnalyticsConfiguration``
- ``CardConfiguration``
- ``ApplePayConfiguration``
- ``AuthenticationConfiguration``
- ``InstallmentConfiguration``
- ``InstallmentOptions``
- ``Installments``
- ``BillingAddressMode``

## Checkout Results and Callbacks

- ``CheckoutResultCode``
- ``CheckoutError``
- ``AdvancedCheckoutResult``
- ``SessionCheckoutResult``
- ``SessionResponse``
- ``BeforeSubmitData``
- ``BeforeSubmitResult``
- ``BeforeSubmitHandler``
- ``SubmitResult``
- ``SubmitHandler``
- ``AdditionalDetailsResult``
- ``AdditionalDetailsHandler``
- ``DelegatedAuthenticationData``

## Payment Methods

- ``PaymentMethods``

### Abstract payment methods

- ``PaymentMethod``
- ``StoredPaymentMethod``
- ``AnyCardPaymentMethod``
- ``PartialPaymentMethod``
- ``IssuerListPaymentMethod``
- ``AwaitPaymentMethod``
- ``VoucherPaymentMethod``
- ``QRCodePaymentMethod``
- ``DocumentPaymentMethod``
- ``GenericPaymentMethod``

### Card payment methods

- ``CardPaymentMethod``
- ``BCMCPaymentMethod``
- ``StoredCardPaymentMethod``
- ``StoredBCMCPaymentMethod``

### Other payment methods

- ``ACHDirectDebitPaymentMethod``
- ``AffirmPaymentMethod``
- ``ApplePayPaymentMethod``
- ``AtomePaymentMethod``
- ``BACSDirectDebitPaymentMethod``
- ``BLIKPaymentMethod``
- ``BoletoPaymentMethod``
- ``CashAppPayPaymentMethod``
- ``DokuPaymentMethod``
- ``DokuWalletPaymentMethod``
- ``EContextPaymentMethod``
- ``GiftCardPaymentMethod``
- ``MBWayPaymentMethod``
- ``MealVoucherPaymentMethod``
- ``OnlineBankingPaymentMethod``
- ``PayByBankUSPaymentMethod``
- ``PayToPaymentMethod``
- ``QiwiWalletPaymentMethod``
- ``SEPADirectDebitPaymentMethod``
- ``SevenElevenPaymentMethod``
- ``TwintPaymentMethod``
- ``UPIPaymentMethod``
- ``WeChatPayPaymentMethod``
- ``AlfamartPaymentMethod``
- ``IndomaretPaymentMethod``

### Stored payment methods

- ``StoredPayPalPaymentMethod``
- ``StoredACHDirectDebitPaymentMethod``
- ``StoredBLIKPaymentMethod``
- ``StoredCashAppPayPaymentMethod``
- ``StoredTwintPaymentMethod``
- ``StoredGenericPaymentMethod``
- ``StoredPayByBankUSPaymentMethod``
- ``StoredPayToPaymentMethod``

## Payment Method Details

- ``CardDetails``
- ``KCPDetails``
- ``ACHDirectDebitDetails``
- ``AffirmDetails``
- ``ApplePayDetails``
- ``AtomeDetails``
- ``BACSDirectDebitDetails``
- ``BasicPersonalInfoFormDetails``
- ``BLIKDetails``
- ``BoletoDetails``
- ``CashAppPayDetails``
- ``DokuDetails``
- ``DotpayDetails``
- ``EPSDetails``
- ``EntercashDetails``
- ``GiftCardDetails``
- ``GenericPaymentDetails``
- ``IssuerListDetails``
- ``MBWayDetails``
- ``MealVoucherDetails``
- ``MOLPayDetails``
- ``OnlineBankingDetails``
- ``OnlineBankingPolandDetails``
- ``OpenBankingDetails``
- ``PayToDetails``
- ``QiwiWalletDetails``
- ``SEPADirectDebitDetails``
- ``StoredPaymentDetails``
- ``TwintDetails``
- ``UPIComponentDetails``

## Actions

- ``Action``
- ``RedirectAction``
- ``AwaitAction``
- ``RedirectableAwaitAction``
- ``QRCodeAction``
- ``SDKAction``
- ``DocumentAction``
- ``TwintSDKAction``
- ``TwintSDKData``
- ``WeChatPaySDKAction``
- ``WeChatPaySDKData``
- ``AwaitActionDetails``
- ``RedirectDetails``

### Voucher actions

- ``AnyVoucherAction``
- ``VoucherAction``
- ``GenericVoucherAction``
- ``BoletoVoucherAction``
- ``DokuVoucherAction``
- ``MultibancoVoucherAction``
- ``OXXOVoucherAction``
- ``EContextATMVoucherAction``
- ``EContextStoresVoucherAction``

### 3D Secure 2

- ``ThreeDS2Action``
- ``ThreeDS2FingerprintAction``
- ``ThreeDS2ChallengeAction``

## Card Utilities

- ``CardBrand``
- ``CardFundingSource``
- ``CardExpiryDateFormatter``
- ``CardExpiryDateValidator``
- ``CardNumberFormatter``
- ``CardNumberValidator``
- ``CardSecurityCodeFormatter``
- ``CardSecurityCodeValidator``
- ``BinLookupData``
- ``BinLookupBrand``
- ``threeDS2SdkVersion``

## Encryption

- ``CardEncryptor``
- ``BankDetailsEncryptor``
- ``Card``
- ``EncryptedCard``

## Theming and UI

- ``CheckoutTheme``
- ``CheckoutColors``
- ``CheckoutConfigurable``
- ``AdyenFonts``
- ``FontSize``
- ``ViewStyle``
- ``TintableStyle``
- ``ContainerView``
- ``RedirectComponentStyle``

## Public Protocols

- ``Component``
- ``PresentableComponent``
- ``FinalizableComponent``
- ``Details``
- ``AdditionalDetails``
- ``PaymentMethodDetails``
- ``PartialPaymentMethodDetails``
- ``OpaqueEncodable``
- ``AdyenContextAware``
- ``PresentationDelegate``

## Models

- ``AdyenContext``
- ``Amount``
- ``Environment``
- ``PartialPayment``
- ``PartialPaymentOrder``
- ``PaymentComponentData``
- ``ActionComponentData``
- ``PostalAddress``
- ``AddressLookupResult``
- ``ShopperName``
- ``ShopperInteraction``
- ``PrefilledShopperInformation``
- ``BrowserInfo``
- ``Issuer``
- ``PhoneNumber``
- ``PhoneExtension``
- ``PaymentMethodType``
- ``AnyEncodable``

## Utilities

- ``AdyenLogging``
- ``LogoURLProvider``
- ``AmountFormatter``
- ``NumericFormatter``
- ``BrazilSocialSecurityNumberFormatter``
- ``IBANFormatter``
- ``Validator``
- ``LengthValidator``
- ``NumericStringValidator``
- ``AdyenObservable``
- ``adyenSdkVersion``

## Localization

- ``CheckoutLocalizationProvider``
- ``CheckoutLocalizationKey``
