# CheckoutTheme

`CheckoutTheme` lets you apply checkout-wide styling through `CheckoutConfiguration`.

Theme customization in v6 is intentionally scoped to semantic overrides so the SDK can keep the overall checkout UI consistent while still adapting to your app.

## Imports

Import the modules used in this example:

```swift
import Adyen
import AdyenCard
import AdyenCheckout
import AdyenUI
import UIKit
```

## Apply a theme

Configure the theme on `CheckoutConfiguration` before calling `Checkout.setup(...)`:

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

## Merchant-facing builder methods

Start from `CheckoutTheme.default` and override only the parts you need.

| API | Purpose |
| --- | --- |
| `bodyLabel(font:color:disabledColor:textAlignment:)` | Customize the default body label style used across checkout UI. |
| `primaryButton(backgroundColor:textColor:disabledBackgroundColor:disabledTextColor:cornerRadius:)` | Customize the primary action button style. |
| `destructiveButton(backgroundColor:textColor:disabledBackgroundColor:disabledTextColor:cornerRadius:)` | Customize destructive action button styling. |

## Scope

- Configure the theme on `CheckoutConfiguration`, not on the `Checkout` flow instance.
- Theme changes apply across payment components and action handling created from that checkout flow.
- `CheckoutTheme` currently exposes a limited set of semantic style overrides to merchants.
- Localization is configured separately with `CheckoutConfiguration.localizationProvider(_:)`. See [README.md](README.md#localization).

## Related docs

- [v6 foundations](README.md)
- [Card component overview](card.md)
- [Card component: session flow](card-session-flow.md)
- [Card component: advanced flow](card-advanced-flow.md)
- [Migration notes](../../MIGRATION.md)
