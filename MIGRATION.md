# Migration Notes
### 1.11.0
- `AppearanceConfiguration` has changed from a class to a struct.
- The `checkoutButtonTitleTextAttributes`, `checkoutButtonTitleEdgeInsets` and `checkoutButtonCornerRadius` properties on `AppearanceConfiguration` have been deprecated. They are replaced by `checkoutButtonType`, which allows you to pass in a custom button type.

### 1.6.0
- The `Error.canceled` case has been renamed to `Error.cancelled`.
- The deprecated `Error.message` case has been removed.
