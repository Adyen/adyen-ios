# Migration Notes

### 2.7.0

- `provideAdditionalDetails(_:for:detailsHandler:)` in `PaymentControllerDelegate` is now required to be implemented. This is the entry-point for 3D-Secure 2.0 (and WeChat Pay). If you don't do 3D-Secure 2.0 or WeChat Pay, you can leave the implementation empty.

### 2.6.0

- The deployment target has been raised to iOS 10.3.
- `AdditionalPaymentDetails` has been changed from a struct to a protocol.

### 2.0.0
- `CheckoutViewController` and `CheckoutViewControllerDelegate` have been replaced with `CheckoutController` and `CheckoutControllerDelegate`.
- `CheckoutViewControllerCardScanDelegate` has been replaced with `CardScanDelegate`.
- `AppearanceConfiguration` has been replaced with `Appearance`, and now offers much more customization options.
- `PaymentRequest` and `PaymentRequestDelegate` have been replaced with `PaymentController` and `PaymentControllerDelegate`.
- You'll no longer need to handle the return of a redirect in either `CheckoutControllerDelegate`/`PaymentControllerDelegate`. Instead, invoke `Adyen.applicationDidOpen(_:)` in `UIApplicationDelegate.application(_:open:options:)`.
- The separate delegate method in `PaymentControllerDelegate` to return payment details has been removed. Instead, fill in the `details` property of the payment method before returning it in `PaymentControllerDelegate.selectPaymentMethod(from:paymentController:selectionHandler:)`,

### 1.11.0
- `AppearanceConfiguration` has changed from a class to a struct.
- The `checkoutButtonTitleTextAttributes`, `checkoutButtonTitleEdgeInsets` and `checkoutButtonCornerRadius` properties on `AppearanceConfiguration` have been deprecated. They are replaced by `checkoutButtonType`, which allows you to pass in a custom button type.

### 1.6.0
- The `Error.canceled` case has been renamed to `Error.cancelled`.
- The deprecated `Error.message` case has been removed.
