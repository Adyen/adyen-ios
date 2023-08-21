#  Migration Notes

## 4.0.0

- We changed the module structure of the SDK to be more granular and enables merchants to import what they need without too much extra over head, please refer to the read me file for how to import modules using CocoaPods, Carthage or Swift Package Manager.
-  `stopLoading(success:completion:)` is removed.
- When a component flow is concluded (e.g. authroized, pending voucher payment, failure), merchants must to call `finalizeIfNeeded(success:)` .
- When shopper cancels a component flow,  merchants must call `cancelIfNeeded()`.
- All deprecated api's are deleted.
- SDK dropped support for iOS 10.
- All internal SDK calls are handled using `APIContext`. It is created with a `clientKey` and a specific `Environment`.
- When creating a component (a `DropInComponent` or a standalone component) an `APIContext` needs to be passed into the initializer.
- `RedirectComponent` requires `RedirectComponent.presentationDelegate` to be set.  `presentationDelegate` handles presenting the component UI on behalf of the component.
- `ApplePayComponent` needs a `ApplePayComponent.Configuration` object to be injected to configure the component.  Old `ApplePayComponent.paymentMethod`, `ApplePayComponent.summaryItems`, `ApplePayComponent.requiredBillingContactFields`, `ApplePayComponent.merchantIdentifier`, and `ApplePayComponent.requiredShippingContactFields` are now moved to the `ApplePayComponent.Configuration` object.
- Parameter `payment` moved from constuctor of `ApplePayComponent` to constructor of `ApplePayComponent.Configuration`.
- `CardComponent` configuration properies like `showsSecurityCodeField`, `showsStorePaymentMethodField`, `showsSecurityCodeField`, `stored`, and `excludedCardTypes` are moved to `CardComponent.Configuration` object.
- Property `payment` moved from `PresentableComponent` to `PaymentComponent`.
- `DropInActionComponent` renamed into `AdyenActionComponent` and moved to `AdyenActions` module. It could be used outside of `AdyenDropIn`.
- `DropInComponent.PaymentMethodsConfiguration` renamed into `DropInComponent.Configuration.`
- Add new method `didComplete(from component: DropInComponent)` to `DropInComponentDelegate` and `ActionComponentDelegate`.
- Method `didCancel(component: PresentableComponent, from dropInComponent: DropInComponent)` changed to `didCancel(component: PaymentComponent, from dropInComponent: DropInComponent)` in `DropInComponentDelegate`.
- Remove `cancelCallback` from `ApplePayComponent`, implement `PaymentComponentDelegate.didFail(error:component:)` instead:
```
func didFail(with error: Error, from component: PaymentComponent) {
  let isCancelled = (error as? ComponentError) == .cancelled
}
```
- In `Adyen` Module, object `Amount` now implements `Codable`.
- Method `present(component: PresentableComponent, disableCloseButton: Bool)` simplified into `present(component: PresentableComponent)` in `PresentationDelegate`.
- To proccess voucher payments your app's Info.plist must contain `NSPhotoLibraryAddUsageDescription`.
- ApplePayComponent returns token in Base64 format. To get information out of it - decode Base64 data in UTF8 string and treat as JSON. For reference, Adyen API expects `applePayToken` in one of 3 following formats: Base64 string; escaped JSON string; JSON object.
- Move `Payment.Amount` as a standalone struct `Amount`.
- Add assert check on `Amount` init to validate currency code.
- Make `countryCode` non-optional for `Payment`.
- Add assert check on `Payment` init to validate country code.
- Move individual `ActionComponent` styles into one struct `ActionComponentStyle`, which is an instance variable in `DropInComponent.Style`.

## 4.10.6
- `Observable` has been renamed to `AdyenObservable` to avoid name collision with `@Observable` swift macro.
