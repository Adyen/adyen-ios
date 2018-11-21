# Adyen SDK for iOS

With Adyen SDK you can help your shoppers pay with a payment method of their choice, selected from a dynamically generated list of available payment methods. Method availability is based on shoppers’ location, transaction currency, and transaction amount.

You can integrate the SDK in two ways: either make use of the default UI components and flows preconfigured by Adyen (Quick integration), or implement your own UI and checkout experience (Custom integration).

<img src="https://user-images.githubusercontent.com/8394738/43137349-ec92b254-8f4b-11e8-8dc7-9e97c0a5570a.png" width="256px" height="516px" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/8394738/43137355-ef9fa150-8f4b-11e8-9cf7-b5693302e56c.png" width="256px" height="516px" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/8394738/43137351-ede41d46-8f4b-11e8-87fb-75f3fb4cc7a5.png" width="256px" height="516px" />

## Installation

The Adyen SDK is available through either [CocoaPods](http://cocoapods.org) or [Carthage](https://github.com/Carthage/Carthage).

### CocoaPods

1. Add `pod 'Adyen'` to your `Podfile`.
2. Run `pod install`.

_If you're not using `use_frameworks!` in your `Podfile`, refer to [our wiki](https://github.com/Adyen/adyen-ios/wiki/Using-Adyen-as-a-static-framework) to prevent issues when using Adyen as a static framework._

### Carthage

1. Add `github "adyen/adyen-ios"` to your `Cartfile`.
2. Run `carthage update`.
3. Link the framework with your target as described in [Carthage Readme](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

## Quick integration

If you want to quickly integrate with Adyen, use the default UI elements that we provide for selecting payment methods, entering payment details, and completing a payment.

For this, instantiate a `CheckoutController` with your view controller, and call `start()` to present the checkout UI.
```swift
var checkoutController: CheckoutController?

func startCheckout() {
    checkoutController = CheckoutController(presentingViewController: self, delegate: self)
    checkoutController?.start()
}
```

### CheckoutControllerDelegate

The following `CheckoutControllerDelegate` methods should be implemented:

```swift
func requestPaymentSession(withToken token: String, for checkoutController: CheckoutController, responseHandler: @escaping (String) -> Void)
```

This method requires you to fetch a payment session via our [`/paymentSession`](https://docs.adyen.com/api-explorer/#/PaymentSetupAndVerificationService/v32/payments/result) endpoint, and pass it through in the `completion` handler. Upon receiving a valid payment session, the SDK will present a list of available payment methods.


```swift
func didFinish(with result: Result<PaymentResult>, for checkoutController: CheckoutController)
```

This method is invoked when the checkout flow has finished. The result contains either a `PaymentResult`, or an `Error`. You can submit the `PaymentResult`'s `payload` property to our [`/payments/result`](https://docs.adyen.com/api-explorer/#/PaymentSetupAndVerificationService/v32/payments/result) endpoint to verify the payment on your server.

### Handling Redirects

In order to correctly handle a redirect to an external website, make sure to let our SDK know when the shopper returns to your app by implementing the following in your `UIApplicationDelegate`:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
    Adyen.applicationDidOpen(url)

    return true
}
```

For implementation details, refer to the [Quick integration guide](https://docs.adyen.com/developers/checkout/ios/quick-integration-ios).

## Custom integration

With custom integration you will have full control over the payment flow and will be able to implement your own unique checkout experience.

This approach requires instantiating and starting a `PaymentController` and implementing the `PaymentControllerDelegate` protocol for callbacks. The `PaymentControllerDelegate` callbacks will provide you with a list of available payment methods, the URL for payment methods that require an external flow, and the result of payment processing.

For implementation details, refer to the [Custom integration guide](https://docs.adyen.com/developers/checkout/ios/custom-integration-ios).

## Examples

You can find examples of both quick and custom integrations in the Examples folder of this repository.

## See also

 * [Complete Documentation](https://docs.adyen.com/developers/checkout/ios)

 * [SDK Reference](https://adyen.github.io/adyen-ios/Docs/index.html)

 * [Migration Notes](https://github.com/Adyen/adyen-ios/blob/master/MIGRATION.md)


## License

This repository is open source and available under the MIT license. For more information, see the LICENSE file.
