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
let theme = CheckoutTheme(
    colors: CheckoutColors(
        background: .systemBackground,
        container: .secondarySystemBackground,
        primary: .black,
        textOnPrimary: .white,
        highlight: .systemBlue,
        destructive: .systemRed,
        text: .label,
        textSecondary: .secondaryLabel
    )
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

## Color overrides

Start from `CheckoutColors.default` and override only the tokens you need.

| API | Purpose |
| --- | --- |
| `background` | Background color for checkout screens and surfaces. |
| `container` | Background color for secondary containers such as form fields. |
| `containerOutline` | Outline color for bordered containers. |
| `primary` | Primary action background color. |
| `textOnPrimary` | Text color used on primary actions. |
| `highlight` | Accent color for interactive highlights. |
| `destructive` | Destructive action background or emphasis color. |
| `textOnDestructive` | Text color used on destructive actions. |
| `disabled` | Background color for disabled controls. |
| `textOnDisabled` | Text color used on disabled controls. |
| `separator` | Divider and border separator color. |
| `text` | Primary text color across checkout UI. |
| `textSecondary` | Secondary text color across checkout UI. |

## Scope

- Configure the theme on `CheckoutConfiguration`, not on the `Checkout` flow instance.
- Theme changes apply across payment components and action handling created from that checkout flow.
- `CheckoutTheme` currently exposes shared color palette overrides through `CheckoutColors`.
- Localization is configured separately with `CheckoutConfiguration.localizationProvider(_:)`. See [README.md](README.md#localization).

## Related docs

- [v6 foundations](README.md)
- [Card component overview](card.md)
- [Card component: session flow](card-session-flow.md)
- [Card component: advanced flow](card-advanced-flow.md)
- [Migration notes](../../MIGRATION.md)
