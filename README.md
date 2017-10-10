# Adyen SDK for iOS

With Adyen SDK you can help your shoppers pay with a payment method of their choice, selected from a dynamically generated list of available payment methods. Method availability is based on shoppers’ location, transaction currency, and transaction amount. 

You can integrate the SDK in two ways: either make use of the default UI components and flows preconfigured by Adyen (Quick integration), or implement your own UI and checkout experience (Custom integration).

![Alt text](https://docs.adyen.com/developers/files/28871718/34111550/1/1507627477611/iOSCheckoutDemo.png)

## Installation

Use CocoaPods to integrate the Adyen SDK into your project. For this, add the following line to your Podfile and run `pod install`.

```
pod 'Adyen'
```

## Quick integration

If you want to quickly integrate with Adyen, use the default UI elements that we provide for selecting payment methods, entering payment details, and completing a payment.

For this, instantiate `CheckoutViewController`, present it in your app, and implement the `CheckoutViewControllerDelegate` protocol for callbacks. All UI interactions are handled by Adyen.

```swift
let viewController = CheckoutViewController(delegate: self)
present(viewController, animated: true)
```

The following `CheckoutViewControllerDelegate` methods should be implemented:

```swift
- checkoutViewController:requiresPaymentDataForToken:completion:
```

This method requires you to fetch payment data from your server and pass it to the `completion` handler. Upon receiving valid payment data, the SDK will present a list of available payment methods. 

For your convenience, we provide a [test merchant server](https://checkoutshopper-test.adyen.com/checkoutshopper/demo/easy-integration/merchantserver/). You can find information on setting up your own server [here](https://docs.adyen.com/developers/in-app-integration#checkoutapiimplementyourserver).

```swift
- checkoutViewController:requiresReturnURL:
```

This method will be called if a selected payment method requires user authentication outside of your app environment (in a web browser, native banking app, etc.). Upon payment authorisation, your app will be reopened using the `application(_:open:options:)` callback of `UIApplicationDelegate`. The URL used to open your app should be passed to the completion handler.

```swift
- checkoutViewController:didFinishWith:
```

This method will provide you with the result of the completed payment request (authorised, refused, etc.).

For implementation details, refer to the [Quick integration guide](https://docs.adyen.com/developers/in-app-integration?platform=inapp-ios).

## Custom integration

With custom integration you will have full control over the payment flow and will be able to implement your own unique checkout experience. 

This approach requires instantiating and starting a `PaymentRequest` and implementing the `PaymentRequestDelegate` protocol for callbacks. The `PaymentRequestDelegate` callbacks will provide you with a list of available payment methods, the URL for payment methods that require an external flow, and the result of payment processing.

For implementation details, refer to the [Custom integration guide](https://docs.adyen.com/developers/in-app-integration/custom-integration).

## Examples

You can find examples of both quick and custom integrations in the Examples folder of this repository.

## See also

 * [Complete Documentation](https://docs.adyen.com/developers/in-app-integration?platform=inapp-ios)

 * [SDK Reference](https://adyen.github.io/adyen-ios/Docs/index.html)

 * [Migration Notes](https://github.com/Adyen/adyen-ios/blob/master/MIGRATION.md)


## License

This repository is open source and available under the MIT license. For more information, see the LICENSE file.
