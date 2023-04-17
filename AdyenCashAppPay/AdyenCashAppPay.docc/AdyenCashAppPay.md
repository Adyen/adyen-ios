# ``AdyenCashAppPay``

This module is used for supporting the Cash App Pay payment method via the `CashAppPayComponent`. In order to support Cash App Pay, make sure to include this module in your application.
You will also need a Client ID from Cash App, configured in your customer area. 

## Overview

The flow for Cash App Pay starts with the `CashAppPayComponent`. After pressing the button on the component, your app will redirect to the Cash App mobile app so the shopper can autherize the payment, after which the Cash App Pay SDK will return back to your app via the `redirectURL` you need to provide to the component. 
See [Cash App Pay url handling](https://github.com/cashapp/cash-app-pay-ios-sdk#implement-url-handling-) for more details.

After returning to your app from Cash App, the component will be ready for the payment. If using `AdyenSession` as your component's delegate, the payment will be handled automatically.
If not, the `didSubmit` method will be triggered for your server to make the `/payments` call. 

### Drop-in
To support Cash App Pay in Drop-in, set the `cashAppPay` property of Drop-in's configuration instance.
```
dropInConfiguration.cashAppPay = CashAppPayConfiguration(redirectURL: URL(string: "yourAppURLOrScheme"))
```

Set your `AdyenSession` instance as Drop-in's delegate to let it handle the flow.
```
dropIn.delegate = self.session
```

Present the Drop-in's view (modally, in a navigation stack, etc).
```
navigationController.present(dropIn.viewController)
```

### Components
Create a `CashAppPayConfiguration` instance with at least the redirect URL that is unique to your app. 

```
let configuration = CashAppPayConfiguration(redirectURL: URL(string: "yourAppURLOrScheme"))
```
For the rest of the optional parameters, refer to the `CashAppPayConfiguration` object.

Create a `CashAppPayPaymentMethod` instance from your payment methods list.
```
let paymentMethod = paymentMethods.paymentMethod(ofType: CashAppPayPaymentMethod.self)
```

Create the the `CashAppPayComponent` with the `paymentMethod` and the `configuration`.
```
let component = CashAppPayComponent(paymentMethod: paymentMethod, context: adyenContext, configuration: configuration)
```

Set your `AdyenSession` instance as the delegate to let it handle the flow.
```
component.delegate = self.adyenSession
```

Present your component's view (modally, in a navigation stack, etc).
```
navigationController.present(component.viewController)
```

## Recurring Payment

`CashAppPayComponent` supports recurring payments via its `configuration` property in `CashAppPayConfiguration` class. 
If you are using the default integration with the `/sessions` call, you will need to set `recurringProcessingModel` and `storePaymentMethodMode` properties (v70+) ([API Explorer](https://docs.adyen.com/api-explorer/Checkout/70/post/sessions#request-storePaymentMethodMode))
Showing the switch for storing the payment will be based on the response of the `/sessions` call. The switch will only be visible if you specified `AskForConsent` for `storePaymentMethodMode`. If you specify `Enabled` or `Disabled`, the switch will then be hidden. In which case, specific to this component, you will need to specifiy another flag in the `configuration` to store the payment method since Cash App SDK needs to know explicitly whether to create a recurring request:
```
- storePaymentMethod: To store the payment method. This property is ignored if `showsStorePaymentMethodField` is `true`.
```

If you are using the Advanced Flow (`/paymentMethods` endpoint instead of `/sessions`), then you can modify the `showsStorePaymentMethodField` yourself and if set to `false`, you will need to set `storePaymentMethod` as well for storing the payment method.

After the above configurations, on the default flow, `AdyenSession` will make the required `/payments` call to autherize/store the payment.
On the Advanced Flow, the `didSubmit` method of the component's delegate will contain the required data for your server to make the `/payments` call.
