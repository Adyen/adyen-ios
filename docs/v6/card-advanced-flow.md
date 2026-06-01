# Card component: advanced flow

Use this guide when your backend starts checkout with `/paymentMethods` and handles `/payments` and `/payments/details`.

For shared card configuration, see [card.md](card.md). For shared v6 concepts, see [README.md](README.md).

## When to use advanced flow

Use advanced flow when your backend manages payment submission and additional details explicitly.

## Example

```swift
let configuration = try CheckoutConfiguration(
    environment: .test,
    amount: amount,
    clientKey: clientKey
) {
    CardConfiguration()
        .billingAddressMode(.lookup(onAddressLookup: { searchTerm in
            await yourAddressProvider.searchAsync(searchTerm)
        }))
        .onBinChange { bin in
            print("BIN: \(bin)")
        }
        .onBinLookup { brands in
            print("Brands: \(brands)")
        }
}
.localizationProvider(DemoLocalizationProvider())
.theme(theme)

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

Theme and localization are configured on `CheckoutConfiguration` before calling `Checkout.setup(...)`. See [theme.md](theme.md) and [README.md](README.md#localization).

## Complete working example

- [Demo/Common/IntegrationExamples/AdvancedFlow/Components/CardComponentAdvancedFlowExample.swift](../../Demo/Common/IntegrationExamples/AdvancedFlow/Components/CardComponentAdvancedFlowExample.swift)

## Related docs

- [Card component overview](card.md)
- [Card component: session flow](card-session-flow.md)
- [Checkout theme](theme.md)
- [Migration notes](../../MIGRATION.md)
