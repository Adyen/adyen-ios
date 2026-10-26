#  Migration Notes

## 6.0.0-alpha.1

See also:

- [guides/v6/README.md](guides/v6/README.md)
- [guides/v6/card.md](guides/v6/card.md)
- [guides/v6/theme.md](guides/v6/theme.md)

### Drop-in configuration

Drop-in-specific behavior is configured through `DropInConfiguration` in the `CheckoutConfiguration` DSL. Component configuration,
localization, and styling remain checkout-wide or component-specific:

```swift
let configuration = try CheckoutConfiguration(
    environment: .test,
    clientKey: clientKey
) {
    DropInConfiguration()
        .hideStoredPaymentMethods(false)
        .startWithLastStoredPaymentMethod(true)

    CardConfiguration()
}
```

`hideStoredPaymentMethods` affects only the payment method list. It remains independent from
`startWithLastStoredPaymentMethod`, so Drop-in can start with a stored method while hiding the stored section from the list.

Stored payment method removal is available only through Session Checkout when enabled by the session response.

Drop-in now always skips the payment method list when exactly one presentable regular payment method is available. The former
`allowsSkippingPaymentList` merchant setting has been removed, and its previous default of `false` no longer applies.

`CheckoutConfiguration.showsSubmitButton(_:)` applies only to components created with `createPaymentComponent`. Drop-in
ignores it and always shows the submit buttons of the components it presents.

### Drop-in creation

In v5, merchants initialized `DropInComponent` directly, supplied component and action configuration through its nested
configuration types, and implemented Drop-in delegates.

In v6, add `DropInConfiguration` and payment-method configurations to `CheckoutConfiguration`, set up Checkout, and create
the public Drop-in facade from the resulting flow:

```swift
let configuration = try CheckoutConfiguration(
    environment: .test,
    clientKey: clientKey
) {
    DropInConfiguration()
        .hideStoredPaymentMethods(false)
        .startWithLastStoredPaymentMethod(true)

    CardConfiguration()
    AuthenticationConfiguration()
        .requestorAppURL(URL(string: "https://your-domain.example/adyen")!)
}

let callbacks = CheckoutCallbacks(
    onComplete: { result in
        print(result.resultCode)
    },
    onFailure: { error in
        print(error.localizedDescription)
    }
)

let checkout = try await Checkout.setup(
    with: sessionResponse,
    configuration: configuration,
    callbacks: callbacks
)

let dropIn = try checkout.createDropIn()
present(dropIn.viewController, animated: true)
```

Retain both the checkout flow and `CheckoutDropInComponent` while Drop-in is active. Each `createDropIn()` call returns a
fresh component. Creation throws `CheckoutError` with code `.paymentMethodFailure` when no supported payment method can be
assembled.

`CheckoutDropInComponent` exposes only its `viewController`. The underlying Drop-in implementation and its v5 delegates are
not part of the v6 public API.

### Core objects

#### Generic payment models

The following public models have been renamed:

| Before | After |
|---|---|
| `InstantPaymentMethod` | `GenericPaymentMethod` |
| `StoredInstantPaymentMethod` | `StoredGenericPaymentMethod` |
| `InstantPaymentDetails` | `GenericPaymentDetails` |

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
    clientKey: clientKey
) {
    CardConfiguration()
    AuthenticationConfiguration()
        .requestorAppURL(URL(string: "https://your-domain.example/adyen")!)
}

let callbacks = CheckoutCallbacks(
    onComplete: { result in
        print(result.resultCode)
    },
    onFailure: { error in
        print(error.localizedDescription)
    }
)
.onBeforeSubmit { data in
    .proceed(data: data, sessionData: nil)
}

let checkout = try await Checkout.setup(
    with: sessionResponse,
    configuration: configuration,
    callbacks: callbacks
)
```

#### Advanced flow

The advanced flow is not available in this release. Use the session flow for payment components.
The `Checkout.setup(with: PaymentMethods, configuration:callbacks:)` overload, `AdvancedCheckoutCallbacks`,
`CheckoutSubmitHandler`, `SubmitResult` and `PartialPayment` are package-only and cannot be used by merchant integrations.
`AdvancedCheckoutResult` remains public because action-only completion callbacks use it.

#### Checkout callbacks

Pass callbacks to `Checkout.setup(..., callbacks:)` rather than chaining them on the returned checkout.
`CheckoutCallbacks(onComplete:onFailure:)` requires both result handlers for session checkout. Session setup now returns
`Checkout`; `SessionCheckout` has been removed, and `SessionCheckoutResult` is renamed to `CheckoutResult`.
Use `.onBeforeSubmit` and `.onAction` on the callbacks value for optional behavior. Modifiers return a copy, so retain the returned value.

Action-only setup requires `ActionOnlyCheckoutCallbacks(onAdditionalDetails:onFailure:)`. Its `.onComplete` and `.onAction`
modifiers are optional. All handlers are supplied before setup, and callbacks cannot be changed on an active checkout.

#### Checkout instances

`Checkout` is now a final instance class as well as the setup entry point. Replace `PaymentCheckout` type annotations
with `Checkout`; static calls such as `Checkout.setup(...)` and `Checkout.handleReturn(url:)` keep their names.
`ActionOnlyCheckout` remains a separate final class and does not expose payment component or Drop-in creation.

`BaseCheckout` is removed. The two checkout types no longer share a public superclass; update helpers, extensions,
and stored properties that previously used it. Each checkout owns its core directly, and flow-specific callback
requirements remain unchanged.

#### Available payment methods

`Checkout` exposes non-optional regular and stored payment-method arrays:

```swift
let paymentMethods = checkout.paymentMethods
let storedPaymentMethods = checkout.storedPaymentMethods
```

These replace the interim `checkout.paymentMethods?.regular` and `checkout.paymentMethods?.stored` access paths. Missing payment-method data is represented by an empty array.

#### Payment method availability

In v5, a payment method that couldn't be used on the device only failed when you created its component, for example `ApplePayComponent` throwing `deviceDoesNotSupportApplePay`. In v6, `Checkout` lets you check first:

```swift
if checkout.isPaymentMethodAvailable(for: .applePay) {
    let component = try checkout.createPaymentComponent(for: .applePay)
}
```

`isPaymentMethodAvailable(for:)` never throws. It returns `false` when the payment method isn't in the checkout's payment methods, or when the device or configuration doesn't meet its requirements. Payment methods without such requirements return `true`. Drop-in uses the same check to hide unavailable payment methods.

#### Action presentation

Both `CheckoutCallbacks` and `ActionOnlyCheckoutCallbacks` expose the optional `onAction(_:)` modifier, invoked once the SDK has built the view controller for an action. It hands over both the action's `ActionData` and the `UIViewController`, so you decide how the action is presented:

```swift
.onAction { actionData, actionViewController in
    print(actionData.type)
    navigationController.present(actionViewController, animated: true)
}
```

`ActionData.type` is an `ActionType`, a `RawRepresentable` struct with the known values `redirect`, `nativeRedirect`, `threeDS2`, `sdk`, `qrCode`, `await` and `voucher`. It is a struct rather than an enum so that new action types do not break exhaustive `switch` statements in your code — always handle unknown values. BACS Direct Debit mandates are returned as `voucher` actions and are surfaced as such. When no handler is set, the SDK presents the view controller on the payment component that started the flow; in the action-only flow there is no such component, so a handler is required.

`onAction(_:)` replaces the `presentationDelegate:` parameter of `Checkout.setup(...)`, which has been removed along with the public `PresentationDelegate` protocol. Drop the argument and the conformance from your integration.

Drop-in presents actions within its own navigation stack, so `onAction(_:)` is not invoked for actions raised inside a Drop-in flow.

#### Summary

- `Checkout.setup(...)` replaces `AdyenSession.initialize(...)` for the new public v6 flows.
- `CheckoutConfiguration` replaces flow-specific setup objects as the main integration entry point.
- Closure callbacks replace the public delegate-first flow setup for submission and completion handling.
- `Checkout` creates payment components for the active flow. The advanced flow is not available in this release.
- `isPaymentMethodAvailable(for:)` checks whether a payment method can be used on the device before creating its component.
- `onAction(_:)` exposes the action's `ActionData` and the `UIViewController` the SDK built for it.
- `PresentationDelegate` and the `presentationDelegate:` parameter of `Checkout.setup(...)` are removed in favour of `onAction(_:)`.
- Theme and localization are configured on `CheckoutConfiguration` through `theme(_:)` and `localizationProvider(_:)`.
- Callback handler typealiases, including `CheckoutAdditionalDetailsHandler`, `CheckoutBeforeSubmitHandler` and `CheckoutActionHandler`, are now package-only. Public callback methods declare the closure signature inline. If your integration explicitly names a handler typealias, replace it with the corresponding closure type; move closure-based calls onto the callbacks value passed to setup.
- `FinalizableComponent` and `Component.finalizeIfNeeded(with:completion:)` are no longer public, and `DropInComponent` no longer conforms to `FinalizableComponent`. Checkout ends the payment in the component itself and then reports the result through `onComplete` or `onFailure`.

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
let callbacks = CheckoutCallbacks(
    onComplete: { result in
        print(result.resultCode)
    },
    onFailure: { error in
        print(error.localizedDescription)
    }
)

let checkout = try await Checkout.setup(
    with: sessionResponse,
    configuration: configuration,
    callbacks: callbacks
)

let component = try checkout.createPaymentComponent(for: .scheme)
```

#### Callback migration

- `CardComponentDelegate.didChangeBIN` -> `CardCallbacks.onBinChange(_:)`
- card brand detection callbacks -> `CardCallbacks.onBinLookup(_:)`
- component styling moves from per-component form styling to checkout-wide `CheckoutTheme`

The interim `CardConfiguration.onBinChange(_:)` and `onBinLookup(_:)` modifiers have been removed.
Put `CardCallbacks` in the additional callbacks block of `CheckoutCallbacks`, not in `CheckoutConfiguration`
or a trailing block on `Checkout.setup`:

```swift
let callbacks = CheckoutCallbacks(
    onComplete: { result in
        print(result.resultCode)
    },
    onFailure: { error in
        print(error.localizedDescription)
    }
) {
    CardCallbacks()
        .onBinChange { bin in
            print(bin)
        }
        .onBinLookup { data in
            print(data.brands)
        }
}
```

The block is optional and supports conditional entries. When a callback type appears more than once,
the last whole value replaces the earlier value. Additional callbacks apply to both standalone components
and components created inside Drop-in. Action-only callbacks do not accept an additional callbacks block.

#### Address lookup callbacks

`BillingAddressMode.lookup` now accepts only `hideForCardBrands`. Move its former `onAddressLookup` closure
into `AddressCallbacks(onAddressLookup:)`, and its optional `onAddressSelected` closure into the
`AddressCallbacks.onAddressSelected(_:)` modifier. Include that value in the same checkout callbacks block
as `CardCallbacks`. Configure the UI separately with `CardConfiguration().billingAddressMode(.lookup())`.

The lookup closure still receives a search term and asynchronously returns `[AddressLookupResult]`.
The selection closure still receives the selected result and asynchronously returns a `PostalAddress`,
or throws. Without the selection handler, the result's postal address is used as-is.
When a card configuration uses `.lookup()` and the checkout callbacks contain no `AddressCallbacks`,
`Checkout.setup` throws `CheckoutError` with the `.invalidConfiguration` code before making any network request.

### Apple Pay component

In v5, Apple Pay's `viewController` was the Apple Pay sheet, and the component could only be used once. `PreApplePayComponent`
showed an intermediate screen with the Apple Pay button.

In v6, the Apple Pay component shows the Apple Pay button itself:

- `viewController` is a screen that contains only the Apple Pay button. Presenting it no longer opens the Apple Pay sheet.
  When `showsSubmitButton(false)` is set on `CheckoutConfiguration`, the screen is empty.
- To use your own Apple Pay button, call `submit()` on the component when the shopper taps it. This opens the Apple Pay sheet.
- The component can be reused after the shopper cancels the sheet or a payment fails.
- An invalid payment request no longer makes creating the component fail. The failure callback receives
  `ApplePayComponent.Error.invalidPaymentRequest` when the sheet can't be opened.
- `ApplePayComponent.Error.submitNotSupported` is removed.
- Drop-in shows the Apple Pay button above the payment methods list, also when `showsSubmitButton(false)` is set.
- `onComplete` and `onFailure` are called after the Apple Pay sheet has shown the result and is dismissed.
- When `onSelectShippingContact`, `onSelectShippingMethod`, `onChangeCouponCode` or `onSelectPaymentMethod` returns
  invalid summary items, the Apple Pay sheet closes and `onFailure` is called once with the validation error, for example
  `ApplePayComponent.Error.negativeGrandTotal`. The shopper can't continue paying with the previous items.

Set the button's type, style and corner radius with `ApplePayButtonAppearance`. If you don't set a corner radius, the button keeps the system's default corner radius:

```swift
try ApplePayConfiguration(paymentRequest: paymentRequest)
    .buttonAppearance(ApplePayButtonAppearance(buttonType: .buy, buttonStyle: .black, cornerRadius: 8))
```

### BACS Direct Debit component

In v5, the BACS Direct Debit component had two screens: the shopper filled in the form, then reviewed their details on a
confirmation screen before paying.

In v6, the component has a single screen:

- The shopper pays directly from the form. The confirmation screen is removed.
- To use your own submit button, set `showsSubmitButton(false)` on `CheckoutConfiguration` and call `submit()` on the
  component when the shopper taps it.
- Create the component with `checkout.createPaymentComponent(for: .bacsDirectDebit)`.
- `BACSDirectDebitDetails` has a new `shopperEmail` property containing the email address the shopper entered, and
  `PaymentComponentData.emailAddress` now returns it. The initializer has a matching `shopperEmail` parameter that
  defaults to `nil`, so existing code keeps compiling.

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
