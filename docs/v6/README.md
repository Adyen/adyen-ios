# Adyen iOS v6

This guide covers the v6 checkout entry points and the shared concepts used by all payment method docs.

For card-specific configuration and examples, see [card.md](card.md). For migration notes, see [../../MIGRATION.md](../../MIGRATION.md).

## Overview

The public integration surface is centered around four concepts:

- `Checkout.setup(...)` is the entry point for checkout flows.
- `CheckoutConfiguration` is the shared configuration container.
- Flow callbacks are configured with closures.
- Payment components are created from `SessionCheckout` or `AdvancedCheckout`.

## Installation

Import `AdyenCheckout` together with the modules used by your flow:

```swift
import Adyen
import AdyenCheckout
```

`AdyenCheckout` provides the setup APIs for session, advanced, and action-only flows.

## CheckoutConfiguration

`CheckoutConfiguration` is the checkout-wide container for:

- environment, amount, and client key
- component-specific configuration objects
- checkout-wide options such as `showsSubmitButton(_:)`
- theming and localization configured through `CheckoutConfiguration`

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
```

Use the builder closure to register component configuration objects that should apply to the flow.

## Session flow

Use the session flow when your backend starts checkout with `/sessions`.

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

let component = try checkout.createPaymentComponent(for: .scheme)
```

`SessionCheckout` can:

- create an individual payment component with `createPaymentComponent(for:)`
- create a Drop-in with `createDropIn()`
- let you inspect or patch shopper data before submit with `onBeforeSubmit(_:)`

## Advanced flow

Use the advanced flow when your backend starts checkout with `/paymentMethods` and handles `/payments` and `/payments/details`.

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

let component = try checkout.createPaymentComponent(for: .scheme)
```

`AdvancedCheckout` can:

- create an individual payment component with `createPaymentComponent(for:)`
- create a Drop-in with `createDropIn()`
- expose `onSubmit(_:)` for `/payments`
- expose `onAdditionalDetails(_:)` for `/payments/details`

## Action-only flow

If your app only needs to handle actions, you can set up checkout without `PaymentMethods` or `SessionResponse`:

```swift
let checkout = try await Checkout.setup(
    configuration: configuration,
    presentationDelegate: self
)
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

Call `checkout.handle(action:)` when your backend returns an action.

## PresentationDelegate

Pass a `PresentationDelegate` if you want checkout to present action components from your own UI layer:

```swift
extension CheckoutViewController: PresentationDelegate {
    func present(component: PresentableComponent) {
        present(component.viewController, animated: true)
    }
}
```

## Presenting a payment component

`createPaymentComponent(for:)` returns `CheckoutPaymentComponent`. Use its `viewController` for presentation.

```swift
guard let viewController = component.viewController else { return }

let navigationController = UINavigationController(rootViewController: viewController)
viewController.navigationItem.leftBarButtonItem = .init(
    barButtonSystemItem: .cancel,
    target: self,
    action: #selector(cancelPressed)
)

present(navigationController, animated: true)
```

## Theme

Apply shared styling on `CheckoutConfiguration` before creating checkout:

```swift
let theme = CheckoutTheme.default
    .bodyLabel(color: .secondaryLabel)
    .primaryButton(
        backgroundColor: .black,
        textColor: .white,
        cornerRadius: 12
    )

let configuration = try CheckoutConfiguration(
    environment: .test,
    amount: amount,
    clientKey: clientKey
) {
    CardConfiguration()
}
.theme(theme)
```

The same theme is used by the payment components and action handling created from that checkout flow.

## Localization

Use `localizationProvider(_:)` on `CheckoutConfiguration` for programmatic string overrides across the checkout flow:

```swift
struct DemoLocalizationProvider: CheckoutLocalizationProvider {
    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        switch (key, locale.languageCode) {
        case (.cardNumber, "en"):
            return "Custom Card Number"
        case (.cardSecurityCode, "en"):
            return "Custom CVC"
        default:
            return nil
        }
    }
}

let configuration = try CheckoutConfiguration(
    environment: .test,
    amount: amount,
    clientKey: clientKey
) {
    CardConfiguration()
}
.localizationProvider(DemoLocalizationProvider())
```

Use app-bundle `.strings` or `.xcstrings` files when you want to add a fully new language. Use `localizationProvider(_:)` when you want targeted runtime overrides.

## Redirects

If checkout redirects the shopper out of your app, forward the return URL to `RedirectComponent`:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return RedirectComponent.applicationDidOpen(from: url)
}
```

## Next steps

- [Card component guide](card.md)
- [Migration notes](../../MIGRATION.md)
