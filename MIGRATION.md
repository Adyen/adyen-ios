#  Migration Notes

## 4.0.0

- We changed the module structure of the SDK to be more granular and enables merchants to import what they need without too much extra over head, please refer to the read me file for how to import modules using CocoaPods, Carthage or Swift Package Manager.
- When a payment is concluded, merchants must to call `finalizeIfNeeded(success:)` .
- When user cancles a component,  merchants must to call `cancelIfNeeded()`.
- To make a component stop its loading animation if any,  merchants should call `stopLoadingIfNeeded()`.
- All deprecated api's in `3.8.x`  are deleted.
- SDK dropped support for iOS 10.
- `RedirectComponent.presentationDelegate` needs to be set.  `presentationDelegate` handles presenting the component UI on behalf of the component.
- `ApplePayComponent` needs a `ApplePayComponent.Configuration` object to be injected to configure the component.  Old `ApplePayComponent.paymentMethod`, `ApplePayComponent.summaryItems`, `ApplePayComponent.requiredBillingContactFields`, `ApplePayComponent.merchantIdentifier`, and `ApplePayComponent.requiredShippingContactFields` are now moved to the `ApplePayComponent.Configuration` object.
- Parameter `payment` moved from constuctor of `ApplePayComponent` to constructor of `ApplePayComponent.Configuration`.
- `CardComponent` configuration properies like `showsSecurityCodeField`, `showsStorePaymentMethodField` ..etc are moved to `CardComponent.Configuration` object.
- Property `payment` moved from `PresentableComponent` to `PaymentComponent`.
- `DropInActionComponent` renamed into `AdyenActionComponent` and moved to `AdyenActions` module. It could be used outside of `AdyenDropIn`.
- Parameter `clientKey` is required for `DropInComponent.PaymentMethodsConfiguration` constructor.
- Add new method `didComplete(from component: DropInComponent)` to `DropInComponentDelegate` and `ActionComponentDelegate`.
- Method `didCancel(component: PresentableComponent, from dropInComponent: DropInComponent)` changed to `didCancel(component: PaymentComponent, from dropInComponent: DropInComponent)` in `DropInComponentDelegate`.
- Remove `cancelCallback` from `ApplePayComponent`.
- Module `Adyen` introduces object `Payment.Amount` as `Encoded`.
- Method `present(component: PresentableComponent, disableCloseButton: Bool)` simplified into `present(component: PresentableComponent)` in `PresentationDelegate`.
- To proccess voucher payments your app's Info.plist should contain `NSPhotoLibraryAddUsageDescription`.
