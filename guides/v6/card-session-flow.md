# Card component: session flow

Use this guide when your backend starts checkout with `/sessions`.

For shared card configuration, see [card.md](card.md). For shared v6 concepts, see [README.md](README.md).

## When to use session flow

Use session flow when you want Adyen to manage the checkout flow from a `SessionResponse`.

Import the modules used in this example:

```swift
import Adyen
import AdyenActions
import AdyenCard
import AdyenCheckout
```

## Example

```swift
let configuration = try CheckoutConfiguration(
    environment: .test,
    amount: amount,
    clientKey: clientKey
) {
    CardConfiguration()
        .onBinChange { bin in
            print("BIN: \(bin)")
        }
        .onBinLookup { brands in
            print("Brands: \(brands)")
        }
    AuthenticationConfiguration()
        .requestorAppURL(URL(string: "https://your-domain.example/adyen")!)
}

let checkout = try await Checkout.setup(
    with: sessionResponse,
    configuration: configuration,
    presentationDelegate: self
)
.onComplete { result in
    print(result.resultCode)
}
.onFailure { error in
    print(error.localizedDescription)
}

let component = try checkout.createPaymentComponent(for: .scheme)
```

## Session-controlled card settings

When you use `/sessions`, some card settings are determined by the session instead of component-level `CardConfiguration` builders:

- `showStorePaymentMethod(_:)` cannot be overridden from `CardConfiguration`. Set the server-side `/sessions` request parameter `storePaymentMethodMode` when creating the session. `askForConsent` shows the toggle, while `enabled` and `disabled` hide it.
- `installmentConfiguration(_:)` and `showInstallmentAmount` are also determined by the session and cannot be overridden from component-level configuration.

Configure these values in your `/sessions` request and do not rely on component-level values to override them.

Optionally apply `.theme(...)` and `.localizationProvider(...)` on `CheckoutConfiguration` before calling `Checkout.setup(...)`. See [theme.md](theme.md) and [README.md](README.md#localization).

## Complete working example

- [Demo/Common/IntegrationExamples/Session/Components/CardComponentExample.swift](../../Demo/Common/IntegrationExamples/Session/Components/CardComponentExample.swift)

## Related docs

- [Card component overview](card.md)
- [Card component: advanced flow](card-advanced-flow.md)
- [Checkout theme](theme.md)
- [Migration notes](../../MIGRATION.md)
