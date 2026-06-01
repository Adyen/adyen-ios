# Card component

This guide covers the shared card component API in v6. For flow-specific setup, use:

- [Card component: session flow](card-session-flow.md)
- [Card component: advanced flow](card-advanced-flow.md)

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

## Flow guides

- Use [card-session-flow.md](card-session-flow.md) when your backend starts checkout with `/sessions`.
- Use [card-advanced-flow.md](card-advanced-flow.md) when your backend starts checkout with `/paymentMethods` and handles `/payments` and `/payments/details`.

## Stored cards

If your checkout flow returns stored payment methods, create a component by stored payment method identifier:

```swift
guard let storedCard = checkout.paymentMethods?.stored.first else { return }

let component = try checkout.createPaymentComponent(for: storedCard.identifier)
```

For stored cards:

- `createPaymentComponent(for: identifier)` looks up the stored payment method in the current checkout flow.
- `showSecurityCodeForStoredCard(_:)` controls whether the shopper should enter CVC again.
- theme and localization settings configured on `CheckoutConfiguration` still apply.

## Related docs

- [v6 foundations](README.md)
- [Card component: session flow](card-session-flow.md)
- [Card component: advanced flow](card-advanced-flow.md)
- [Migration notes](../../MIGRATION.md)
