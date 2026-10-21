# Adyen iOS v6

This guide covers the v6 checkout entry points and the shared concepts used by all payment method docs.

For card-specific configuration and flow guides, see [card.md](card.md) and [card-session-flow.md](card-session-flow.md). For theme customization, see [theme.md](theme.md). For migration notes, see [../../MIGRATION.md](../../MIGRATION.md).

## Overview

The public integration surface is centered around four concepts:

- `Checkout.setup(...)` is the entry point for checkout flows.
- `CheckoutConfiguration` is the shared configuration container.
- Flow callbacks are supplied in a `CheckoutCallbacks` or `ActionOnlyCheckoutCallbacks` value.
- Payment components are created from `PaymentCheckout`.

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

`AdyenCheckout` provides the setup APIs for session and action-only flows. The advanced flow is not available in this release.

## CheckoutConfiguration

`CheckoutConfiguration` is the checkout-wide container for:

- environment and client key
- component-specific configuration objects
- checkout-wide options such as `showsSubmitButton(_:)`
- theming and localization configured through `CheckoutConfiguration`

```swift
let configuration = try CheckoutConfiguration(
    environment: .test,
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

let component = try checkout.createPaymentComponent(for: .scheme)
```

The callbacks value requires `onComplete` and `onFailure`; `.onBeforeSubmit` and `.onAction` are optional modifiers.
Modifiers return a copy. Pass the returned value to setup; callbacks cannot be changed on an active checkout.

In session flow, the SDK gets the `amount` from the `/sessions` response.
For card-specific session-controlled settings such as `showStorePaymentMethod(_:)`, `installmentConfiguration(_:)`, and
`showInstallmentAmount`, see [card-session-flow.md](card-session-flow.md).

`PaymentCheckout` can:

- create an individual payment component with `createPaymentComponent(for:)`
- use `CheckoutCallbacks.onBeforeSubmit(_:)` to inspect or patch shopper data before submit

## Action-only flow

If your app only needs to handle actions, you can set up checkout without `PaymentMethods` or `SessionResponse`:

```swift
let callbacks = ActionOnlyCheckoutCallbacks(
    onAdditionalDetails: { data in
        try await callDetails(with: data)
    },
    onFailure: { error in
        print(error.localizedDescription)
    }
)
.onAction { actionData, actionViewController in
    present(actionViewController, animated: true)
}
.onComplete { result in
    print(result.resultCode)
}

let checkout = try await Checkout.setup(
    configuration: configuration,
    callbacks: callbacks
)
```

`callDetails(with:)` should return `AdditionalDetailsResult`.

Call `checkout.handle(action:)` when your backend returns an action.

## Presenting actions

Checkout builds the view controller for an action — a 3D Secure challenge, a voucher, a QR code — and hands it to `onAction(_:)` together with an `ActionData` describing the action. Present it from your own UI layer:

```swift
.onAction { actionData, actionViewController in
    print(actionData.type)
    present(actionViewController, animated: true)
}
```

`ActionData.type` is an `ActionType`, a `RawRepresentable` struct with the known values `redirect`, `nativeRedirect`, `threeDS2`, `sdk`, `qrCode`, `await` and `voucher`. It is a struct rather than an enum so that new action types do not break exhaustive `switch` statements in your code — always handle unknown values.

`onAction(_:)` is a modifier on both callbacks values, not on the checkout object. When you do not set it, checkout presents the action on the payment component that started the flow. The action-only flow has no such component, so it always needs a handler.

Drop-in presents actions within its own navigation stack, so `onAction(_:)` is not invoked for actions raised inside a Drop-in flow.

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
- [Checkout theme](theme.md)
- [Migration notes](../../MIGRATION.md)
