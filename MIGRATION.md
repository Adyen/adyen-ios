#  Migration Notes

### 4.0.0

- we changed the module structure of the SDK to be more granular and enables merchants to import what they need withour too much extra over head, please refer to the read me file for how to import modules using CocoaPods, Carthage or Swift Package Manager.
- When a payment is concluded, merchants need to call either `stopLoading(completion:)` if the component implements `LoadingComponent` protocol, `finalize(success:)` if it implements `FinalizableComponent` protocol.
- When user cancles a component,  merchants need to call `didCancel` if the component implements `Cancellable` protocol.
- All deprecated api's in `3.8.0`  are deleted.
- `RedirectComponent.presentationDelegate` needs to be set.  `presentationDelegate` handles presenting the component UI on behalf of the component.
- `ApplePayComponent` needs a `ApplePayComponent.Configuration` object to be injected to configure the component.  Old `ApplePayComponent.paymentMethod`, `ApplePayComponent.summaryItems`, `ApplePayComponent.requiredBillingContactFields`, `ApplePayComponent.merchantIdentifier`, and `ApplePayComponent.requiredShippingContactFields` are now moved to the `ApplePayComponent.Configuration` object.
- `CardComponent` configuration properies like `showsSecurityCodeField`, `showsStorePaymentMethodField` ..etc are moved to `CardComponent.Configuration` object.


