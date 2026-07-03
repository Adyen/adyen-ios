# Adyen iOS v6

This guide covers the v6 checkout entry points and the shared concepts used by all payment method docs.

For card-specific configuration and flow guides, see [card.md](card.md), [card-session-flow.md](card-session-flow.md), and [card-advanced-flow.md](card-advanced-flow.md). For theme customization, see [theme.md](theme.md). For migration notes, see [../../MIGRATION.md](../../MIGRATION.md).

## Overview

The public integration surface is centered around four concepts:

- `Checkout.setup(...)` is the entry point for checkout flows.
- `CheckoutConfiguration` is the shared configuration container.
- Flow callbacks are configured with closures.
- Payment components are created from `SessionCheckout` or `AdvancedCheckout`.

## Installation

Import the modules used by these examples:

```swift
import Adyen
import AdyenActions
import AdyenCard
import AdyenCheckout
import AdyenUI
import UIKit
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
        .requestorAppURL(URL(string: "https://your-domain.example/adyen")!)
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
        .requestorAppURL(URL(string: "https://your-domain.example/adyen")!)
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
.onFailure { error in
    print(error.localizedDescription)
}

let component = try checkout.createPaymentComponent(for: .scheme)
```

In session flow, the effective `amount` comes from the `/sessions` response. A client-side `amount` on `CheckoutConfiguration` does not override it. For card-specific session-controlled settings such as `showStorePaymentMethod(_:)`, `installmentConfiguration(_:)`, and `showInstallmentAmount`, see [card-session-flow.md](card-session-flow.md).

`SessionCheckout` can:

- create an individual payment component with `createPaymentComponent(for:)`
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
    try await callPayments(with: data)
}
.onAdditionalDetails { data in
    try await callDetails(with: data)
}
.onComplete { result in
    print(result.resultCode)
}
.onFailure { error in
    print(error.localizedDescription)
}

let component = try checkout.createPaymentComponent(for: .scheme)
```

`callPayments(with:)` should return `SubmitResult`, and `callDetails(with:)` should return `AdditionalDetailsResult`.

`AdvancedCheckout` can:

- create an individual payment component with `createPaymentComponent(for:)`
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
    try await callDetails(with: data)
}
.onComplete { result in
    print(result.resultCode)
}
.onFailure { error in
    print(error.localizedDescription)
}
```

`callDetails(with:)` should return `AdditionalDetailsResult`.

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

For the full `CheckoutTheme` guide and the supported color overrides, see [theme.md](theme.md).

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

## Redirect return URLs

Pass incoming URLs to the SDK so active redirect actions can resume after the shopper returns from a browser or external app.

**UIKit - AppDelegate:**
```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    Checkout.handleReturn(url: url)
    return true
}
```

**UIKit - SceneDelegate:**
```swift
func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
    guard let url = contexts.first?.url else { return }
    Checkout.handleReturn(url: url)
}
```

**SwiftUI:**
```swift
ContentView()
    .onOpenURL { url in Checkout.handleReturn(url: url) }
```

It is safe to pass all incoming URLs; any URL not belonging to an active checkout redirect is ignored.

## Next steps

- [Card component overview](card.md)
- [Card component: session flow](card-session-flow.md)
- [Card component: advanced flow](card-advanced-flow.md)
- [Checkout theme](theme.md)
- [Migration notes](../../MIGRATION.md)
