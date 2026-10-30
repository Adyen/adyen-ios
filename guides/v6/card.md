# Card component

This guide covers the shared card component API in v6. For flow-specific setup, use:

- [Card component: session flow](card-session-flow.md)

For the shared v6 concepts, see [README.md](README.md).

## Imports

Import the modules used by the card guides:

```swift
import Adyen
import AdyenActions
import AdyenCard
import AdyenCheckout
```

## Configure the card component

Register `CardConfiguration` inside `CheckoutConfiguration`:

```swift
let configuration = try CheckoutConfiguration(
    environment: .test,
    clientKey: clientKey
) {
    CardConfiguration()
        .showCardholderName(true)
        .showStorePaymentMethod(true)
        .showSecurityCode(true)
        .showSecurityCodeForStoredCard(true)
        .supportedCardBrands([.visa, .masterCard])
        .billingAddressMode(.full())
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
| `shopperInformation(_:)` | Prefill shopper details. |

When you use [session flow](card-session-flow.md), some card settings, including `showStorePaymentMethod(_:)`, `installmentConfiguration(_:)`, and `showInstallmentAmount`, are determined by the session instead of component-level overrides. For details, see [card-session-flow.md](card-session-flow.md).

## Card callbacks

Keep component configuration in `CardConfiguration`. Put event handlers in `CardCallbacks`, inside the
trailing additional callbacks block of `CheckoutCallbacks`:

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
            print(data.issuingCountryCode, data.brands)
        }
}
```

- `onBinChange(_:)` receives the BIN prefix as the shopper enters the card number.
- `onBinLookup(_:)` receives issuing-country and detected-brand information from BIN lookup.

Modifiers return copies. The additional callbacks block supports `if` and `if`/`else`. If you include the
same callback type more than once, the last whole value wins; its handlers are not merged with earlier values.
The callbacks reach both standalone card components and cards presented inside Drop-in.

## Address lookup callbacks

Enable lookup in the card configuration:

```swift
CardConfiguration()
    .billingAddressMode(.lookup())
```

Then include `AddressCallbacks` in the same checkout callbacks block. Replace `searchAddresses` and
`fetchAddress` below with your address service calls:

```swift
let callbacks = CheckoutCallbacks(
    onComplete: { result in
        print(result.resultCode)
    },
    onFailure: { error in
        print(error.localizedDescription)
    }
) {
    AddressCallbacks(onAddressLookup: { query in
        await searchAddresses(matching: query)
    })
    .onAddressSelected { result in
        try await fetchAddress(for: result)
    }
}
```

`onAddressLookup` is required and returns matching `AddressLookupResult` values. The optional
`onAddressSelected(_:)` modifier can retrieve a complete `PostalAddress` for a partial result.
Without it, the selected result's postal address is used as-is.

`BillingAddressMode.lookup(hideForCardBrands:)` contains configuration only. When lookup is enabled
without `AddressCallbacks`, `Checkout.setup` throws `CheckoutError` with the `.invalidConfiguration` code.

## 3D Secure configuration

3DS2-specific settings are configured with `AuthenticationConfiguration`, not `CardConfiguration`.

Use `requestorAppURL(_:)` when you support 3DS2 out-of-band challenges:

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

## Flow guides

- Use [card-session-flow.md](card-session-flow.md) when your backend starts checkout with `/sessions`.

## Stored cards

If your checkout flow returns stored payment methods, first select a stored card explicitly:

```swift
guard let storedCard = checkout.storedPaymentMethods
    .compactMap({ $0 as? StoredCardPaymentMethod })
    .first else { return }

let component = try checkout.createPaymentComponent(for: storedCard.identifier)
```

For stored cards:

- `createPaymentComponent(for: identifier)` looks up the stored card you selected from the current checkout flow.
- `showSecurityCodeForStoredCard(_:)` controls whether the shopper should enter CVC again.
- theme settings configured on `CheckoutConfiguration` still apply. See [theme.md](theme.md).
- localization settings configured on `CheckoutConfiguration` still apply. See [README.md](README.md#localization).

## Related docs

- [v6 foundations](README.md)
- [Card component: session flow](card-session-flow.md)
- [Checkout theme](theme.md)
- [Migration notes](../../MIGRATION.md)
