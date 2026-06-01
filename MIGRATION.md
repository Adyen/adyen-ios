#  Migration Notes

## 6.0.0-alpha01

See also:

- [docs/v6/README.md](docs/v6/README.md)
- [docs/v6/card.md](docs/v6/card.md)

### Core objects

#### Sessions flow

##### Before (v5)

```swift
let apiContext = try APIContext(environment: .test, clientKey: clientKey)
let context = AdyenContext(apiContext: apiContext, payment: payment)

let configuration = AdyenSession.Configuration(
    sessionIdentifier: response.sessionId,
    initialSessionData: response.sessionData,
    context: context
)

AdyenSession.initialize(
    with: configuration,
    delegate: self,
    presentationDelegate: self
) { result in
    // store session
}
```

##### After (v6)

```swift
let configuration = try CheckoutConfiguration(
    environment: .test,
    amount: amount,
    clientKey: clientKey
) {
    CardConfiguration()
    AuthenticationConfiguration()
        .requestorAppURL(URL(string: "your-app://adyen")!)
}

let checkout = try await Checkout.setup(
    with: sessionResponse,
    configuration: configuration,
    presentationDelegate: self
)
.onBeforeSubmit { data in
    .proceed(data: data, sessionData: nil)
}
.onComplete { result in
    print(result.resultCode)
}
.onError { error in
    print(error.localizedDescription)
}
```

#### Advanced flow

##### Before (v5)

```swift
let apiContext = try APIContext(environment: .test, clientKey: clientKey)
let context = AdyenContext(apiContext: apiContext, payment: payment)

let component = CardComponent(
    paymentMethod: paymentMethod,
    context: context,
    configuration: cardConfiguration
)

component.delegate = self
```

`PaymentComponentDelegate` handled `/payments`, and a separate action component handled `/payments/details` and redirects.

##### After (v6)

```swift
let configuration = try CheckoutConfiguration(
    environment: .test,
    amount: amount,
    clientKey: clientKey
) {
    CardConfiguration()
}

let checkout = try await Checkout.setup(
    with: paymentMethods,
    configuration: configuration,
    presentationDelegate: self
)
.onSubmit { data in
    try await submitToYourServer(data)
}
.onAdditionalDetails { data in
    try await submitAdditionalDetailsToYourServer(data)
}
.onComplete { result in
    print(result.resultCode)
}
.onError { error in
    print(error.localizedDescription)
}
```

#### Summary

- `Checkout.setup(...)` replaces `AdyenSession.initialize(...)` for the new public v6 flows.
- `CheckoutConfiguration` replaces flow-specific setup objects as the main integration entry point.
- Closure callbacks replace the public delegate-first flow setup for submission and completion handling.
- `SessionCheckout` and `AdvancedCheckout` create payment components and Drop-in instances for the active flow.
- Theme and localization are configured on `CheckoutConfiguration` through `theme(_:)` and `localizationProvider(_:)`.

### Card component

#### Configuration object

##### Before (v5)

```swift
var configuration = CardComponent.Configuration()
configuration.showsHolderNameField = true
configuration.showsStorePaymentMethodField = true
configuration.showsSecurityCodeField = true
configuration.allowedCardTypes = [.visa, .masterCard]
configuration.koreanAuthenticationMode = .auto
configuration.socialSecurityNumberMode = .auto
```

##### After (v6)

```swift
let configuration = CardConfiguration()
    .showCardholderName(true)
    .showStorePaymentMethod(true)
    .showSecurityCode(true)
    .supportedCardBrands([.visa, .masterCard])
    .koreanAuthenticationVisibility(.auto)
    .socialSecurityNumberVisibility(.auto)
```

#### Sessions flow

##### Before (v5)

```swift
guard let paymentMethod = session.sessionContext.paymentMethods
    .paymentMethod(ofType: CardPaymentMethod.self) else { return }

let component = CardComponent(
    paymentMethod: paymentMethod,
    context: context,
    configuration: cardConfiguration
)

component.delegate = session
```

##### After (v6)

```swift
let checkout = try await Checkout.setup(
    with: sessionResponse,
    configuration: configuration,
    presentationDelegate: self
)

let component = try checkout.createPaymentComponent(for: .scheme)
```

#### Advanced flow

##### Before (v5)

```swift
guard let paymentMethod = paymentMethods
    .paymentMethod(ofType: CardPaymentMethod.self) else { return }

let component = CardComponent(
    paymentMethod: paymentMethod,
    context: context,
    configuration: cardConfiguration
)

component.cardComponentDelegate = self
component.delegate = self
```

##### After (v6)

```swift
let checkout = try await Checkout.setup(
    with: paymentMethods,
    configuration: configuration,
    presentationDelegate: self
)
.onSubmit { data in
    try await submitToYourServer(data)
}
.onAdditionalDetails { data in
    try await submitAdditionalDetailsToYourServer(data)
}

let component = try checkout.createPaymentComponent(for: .scheme)
```

#### Callback migration

- `CardComponentDelegate.didChangeBIN` -> `CardConfiguration.onBinChange(_:)`
- card brand detection callbacks -> `CardConfiguration.onBinLookup(_:)`
- component styling moves from per-component form styling to checkout-wide `CheckoutTheme`

## 5.5.0
- `telephoneNumber` property of `PrefilledShopperInformation` has been deprecated. Use the `phoneNumber` property if needed.


## 5.3.0
- The `didComplete` method signature of `AdyenSessionDelegate` has changed. You must replace `didComplete(with resultCode: SessionPaymentResultCode, component: Component, session: AdyenSession)` with `didComplete(with result: AdyenSessionResult, component: Component, session: AdyenSession)`. Use the `resultCode` inside of the `AdyenSessionResult` if needed.


## 5.2.0
- `amountToPay` property of `PaymentComponentData` has been deprecated. Use to `amount` property if needed.


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
