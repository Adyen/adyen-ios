# Card component: session flow

Use this guide when your backend starts checkout with `/sessions`.

For shared card configuration, see [card.md](card.md). For shared v6 concepts, see [README.md](README.md).

## When to use session flow

Use session flow when you want Adyen to manage the checkout flow from a `SessionResponse`.

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
        .requestorAppURL(URL(string: "your-app://adyen")!)
}
.theme(theme)
.localizationProvider(DemoLocalizationProvider())

let checkout = try await Checkout.setup(
    with: sessionResponse,
    configuration: configuration,
    presentationDelegate: self
)
.onComplete { result in
    print(result.resultCode)
}
.onError { error in
    print(error.localizedDescription)
}

let component = try checkout.createPaymentComponent(for: .scheme)
```

Theme and localization are configured on `CheckoutConfiguration` before calling `Checkout.setup(...)`. See [theme.md](theme.md) and [README.md](README.md#localization).

## Complete working example

- [Demo/Common/IntegrationExamples/Session/Components/CardComponentExample.swift](../../Demo/Common/IntegrationExamples/Session/Components/CardComponentExample.swift)

## Related docs

- [Card component overview](card.md)
- [Card component: advanced flow](card-advanced-flow.md)
- [Checkout theme](theme.md)
- [Migration notes](../../MIGRATION.md)
