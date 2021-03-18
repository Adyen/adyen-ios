#  Migration Notes

## 4.0.0

- We changed the module structure of the SDK to be more granular and enables merchants to import what they need without too much extra over head, please refer to the read me file for how to import modules using CocoaPods, Carthage or Swift Package Manager.
-  `stopLoading(success:completion:)` is removed.
- When a component flow is concluded (e.g. authroized, pending voucher payment, failure), merchants must to call `finalizeIfNeeded(success:)` .
- When shopper cancels a component flow,  merchants must call `cancelIfNeeded()`.
- All deprecated api's are deleted.
- SDK dropped support for iOS 10.
- `RedirectComponent` requires `RedirectComponent.presentationDelegate` to be set.  `presentationDelegate` handles presenting the component UI on behalf of the component.
- `ApplePayComponent` needs a `ApplePayComponent.Configuration` object to be injected to configure the component.  Old `ApplePayComponent.paymentMethod`, `ApplePayComponent.summaryItems`, `ApplePayComponent.requiredBillingContactFields`, `ApplePayComponent.merchantIdentifier`, and `ApplePayComponent.requiredShippingContactFields` are now moved to the `ApplePayComponent.Configuration` object.
- Parameter `payment` moved from constuctor of `ApplePayComponent` to constructor of `ApplePayComponent.Configuration`.
- `CardComponent` configuration properies like `showsSecurityCodeField`, `showsStorePaymentMethodField`, `showsSecurityCodeField`, `stored`, and `excludedCardTypes` are moved to `CardComponent.Configuration` object.
- Property `payment` moved from `PresentableComponent` to `PaymentComponent`.
- `DropInActionComponent` renamed into `AdyenActionComponent` and moved to `AdyenActions` module. It could be used outside of `AdyenDropIn`.
- Parameter `clientKey` is required for `DropInComponent.PaymentMethodsConfiguration` constructor.
- Add new method `didComplete(from component: DropInComponent)` to `DropInComponentDelegate` and `ActionComponentDelegate`.
- Method `didCancel(component: PresentableComponent, from dropInComponent: DropInComponent)` changed to `didCancel(component: PaymentComponent, from dropInComponent: DropInComponent)` in `DropInComponentDelegate`.
- Remove `cancelCallback` from `ApplePayComponent`, implement `PaymentComponentDelegate.didFail(error:component:)` instead:
```
func didFail(with error: Error, from component: PaymentComponent) {
  let isCancelled = (error as? ComponentError) == .cancelled
}
```
- In `Adyen` Module, object `Payment.Amount` now implements `Codable`.
- Method `present(component: PresentableComponent, disableCloseButton: Bool)` simplified into `present(component: PresentableComponent)` in `PresentationDelegate`.
- To proccess voucher payments your app's Info.plist must contain `NSPhotoLibraryAddUsageDescription`.
