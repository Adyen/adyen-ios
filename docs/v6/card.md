# Card component

This guide covers the v6 card component API built around `Checkout.setup(...)`, `CheckoutConfiguration`, and `CardConfiguration`.

For the shared v6 concepts, see [README.md](README.md).

## Configure the card component

Register `CardConfiguration` inside `CheckoutConfiguration`:

```swift
let configuration = try CheckoutConfiguration(
    environment: .test,
    amount: amount,
    clientKey: clientKey
) {
    CardConfiguration()
        .showCardholderName(true)
        .showStorePaymentMethod(true)
        .showSecurityCode(true)
        .showSecurityCodeForStoredCard(true)
        .supportedCardBrands([.visa, .masterCard])
        .billingAddressMode(.full)
        .billingAddressCountryCodes(["US", "CA"])
        .onBinChange { bin in
            print(bin)
        }
        .onBinLookup { brands in
            print(brands)
        }
}
```

### Public `CardConfiguration` builders

| API | Purpose |
| --- | --- |
| `showCardholderName(_:)` | Show or hide the cardholder name field. |
| `showStorePaymentMethod(_:)` | Show or hide the “store payment method” toggle. |
| `showSecurityCode(_:)` | Show or hide the security code field for regular cards. |
| `showSecurityCodeForStoredCard(_:)` | Show or hide the security code field for stored cards. |
| `koreanAuthenticationVisibility(_:)` | Configure Korean card authentication field visibility. |
| `socialSecurityNumberVisibility(_:)` | Configure CPF/CNPJ visibility for Brazilian cards. |
| `supportedCardBrands(_:)` | Override the card brands exposed by the payment method response. |
| `installmentConfiguration(_:)` | Configure installments. |
| `billingAddressMode(_:)` | Control billing address collection. |
| `billingAddressCountryCodes(_:)` | Restrict the list of countries for billing address collection. |
| `shopperInformation(_:)` | Prefill shopper details. |
| `onBinChange(_:)` | Receive BIN updates while the shopper types. |
| `onBinLookup(_:)` | Receive detected card brands from card number input. |

## 3D Secure configuration

3DS2-specific settings are configured with `AuthenticationConfiguration`, not `CardConfiguration`.

Use `requestorAppURL(_:)` when you support 3DS2 out-of-band challenges:

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

## Session flow

Use `Checkout.setup(with: SessionResponse, ...)` when your backend starts checkout with `/sessions`.

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

Complete working example:

- [Demo/Common/IntegrationExamples/Session/Components/CardComponentExample.swift](../../Demo/Common/IntegrationExamples/Session/Components/CardComponentExample.swift)

## Advanced flow

Use `Checkout.setup(with: PaymentMethods, ...)` when your backend handles `/payments` and `/payments/details`.

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

Complete working example:

- [Demo/Common/IntegrationExamples/AdvancedFlow/Components/CardComponentAdvancedFlowExample.swift](../../Demo/Common/IntegrationExamples/AdvancedFlow/Components/CardComponentAdvancedFlowExample.swift)

## Stored cards

If your checkout flow returns stored payment methods, create a component by stored payment method identifier:

```swift
guard let storedCard = checkout.paymentMethods?.stored.first else { return }

let component = try checkout.createPaymentComponent(for: storedCard.identifier)
```

For stored cards:

- `createPaymentComponent(for: identifier)` looks up the stored payment method in the current checkout flow.
- `showSecurityCodeForStoredCard(_:)` controls whether the shopper should enter CVC again.
- checkout-wide theme and localization settings still apply.

## Related docs

- [v6 foundations](README.md)
- [Migration notes](../../MIGRATION.md)
