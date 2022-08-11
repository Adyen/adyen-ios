#  Migration Notes

## 5.0.0

- `AffirmComponent.style`, `AffirmComponent.shopperInformation` and `AffirmComponent.localizationParameters` moved into new `configuration` property `AffirmComponent.Configuration`;
- `DokuComponent.style`, `DokuComponent.shopperInformation` and `DokuComponent.localizationParameters` moved into new `configuration` property `DokuComponent.Configuration`;
- `MBWayComponent.style`, `MBWayComponent.shopperInformation` and `MBWayComponent.localizationParameters` moved into new `configuration` property `MBWayComponent.Configuration`;
- `QiwiWalletComponent.style` and `QiwiWalletComponent.localizationParameters` moved into new `configuration` property `QiwiWalletComponent.Configuration`;
- `BasicPersonalInfoFormComponent.style` and `BasicPersonalInfoFormComponent.localizationParameters` moved into new `configuration` property `BasicPersonalInfoFormComponent.Configuration`;
- `ACHDirectDebitComponent.style`, `ACHDirectDebitComponent.shopperInformation` and `ACHDirectDebitComponent.localizationParameters` moved into the `configuration` property `ACHDirectDebitComponent.Configuration`;
- `BACSDirectDebitComponent.style`, `BACSDirectDebitComponent.shopperInformation` and `BACSDirectDebitComponent.localizationParameters` moved into the `configuration` property `BACSDirectDebitComponent.Configuration`;
- `BLIKComponent.style` and `BLIKComponent.localizationParameters` moved into new `configuration` property `BLIKComponent.Configuration`;
- `BoletoComponent.style`, `BoletoComponent.shopperInformation` and `BoletoComponent.localizationParameters` moved into the `configuration` property `BoletoComponent.Configuration`;
- `IssuerListComponent.style` and `IssuerListComponent.localizationParameters` moved into new `configuration` property `IssuerListComponent.Configuration`;
- `SEPADirectDebitComponent.style` and `SEPADirectDebitComponent.localizationParameters` moved into new `configuration` property `SEPADirectDebitComponent.Configuration`;
- `ThreeDS2Component.appearanceConfiguration` and `ThreeDS2Component.redirectComponentStyle` moved to `ThreeDS2Component.configuration`;
- `CardComponent.style`, `CardComponent.shopperInformation` and `CardComponent.localizationParameters` moved into the `configuration` property `CardComponent.Configuration`;
- `DropInComponent.style` moved into the `configuration` property `DropInComponent.Configuration`;
- `AwaitComponent.style` and `AwaitComponent.localizationParameters` moved to `AwaitComponent.configuration`;
- `QRCodeComponent.style` and `QRCodeComponent.localizationParameters` moved to `QRCodeComponent.configuration`;
- `VoucherComponent.style` and `VoucherComponent.localizationParameters` moved to `VoucherComponent.configuration`;
- `RedirectComponent.style` moved to `RedirectComponent.configuration`;
- `DocumentComponent.style` and `DocumentComponent.localizationParameters` moved to `DocumentComponent.configuration`;
- `DropInComponentDelegate` has been refactored to be more transparent about which action component or payment component caused the call back;
- Method `didFinalize(with success: Bool)` for `FinalizableComponent` changed to `didFinalize(with success: Bool, completion: (() -> Void)?)`;
- Helper method `finalizeIfNeeded(with success: Bool)` for `Component` changed to `finalizeIfNeeded(with success: Bool, completion: (() -> Void)?)`;
- In `ApplePayComponent.Configuration` init parameter `payment: Payment` changed to `payment: ApplePayPayment`;
- All properties (except for `payment` and `merchantIdentifier`) are removed from `ApplePayComponent.Configuration.init()` and become mutable;
- Refactor `didOpenExternalApplication(_ component:` into `didOpenExternalApplication(component:`;
- `APIContext.init(environment: AnyAPIEnvironment, clientKey: String)` now `throws` exception if client key is invalid;
- Method `requestOrder(_ component: Component, completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void)` changed to `requestOrder(for component: Component, completion: @escaping (Result<PartialPaymentOrder, Error>) -> Void)`
- Method `cancelOrder(_ order: PartialPaymentOrder)` changed to `cancelOrder(_ order: PartialPaymentOrder, component: Component)`
- `CardPaymentMethod.brands` is now a strongly typed Array of `CardType`.
- `StoredCardPaymentMethod.brands` is now a strongly typed Array of `CardType`.
- `StoredCardPaymentMethod.brand` is now a strongly typed `CardType`.
- `PaymentMethods` now has a convenient function `overrideDisplayInformation(ofPaymentMethod:with:)` to override a specific payment method title/subtitle in the DropIn list.
- Every component needs to be initialized with an `AdyenContext` instance that defines the behavior for a payment flow.
- `AnalyticsConfiguration` is the object that defines the behavior of analytics within the SDK. Merchants can enable/disable analytics.
- `CardComponentDelegate.didChangeBIN(:component:)` provides the 8 digit bin in case the PAN is greater than 16 digits.
- `CardComponentDelegate.didSubmit(lastFour:finalBIN:component)` now has a new parameter `finalBIN` that provides the final BIN after shopper submits the card details.
