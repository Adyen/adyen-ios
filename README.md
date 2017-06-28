# Adyen SDK for iOS

With Adyen SDK you can dynamically list all relevant payment methods for a specific transaction, so your shoppers can always pay with the method of their choice. The methods are listed based on the shopper's country, transaction currency, and amount.

## Installation
Adyen SDK can be integrated into your project using CocoaPods. For this, add the following line to your Podfile and run `pod install`.

```
pod 'Adyen'
```

## Quick integration

It is very easy to enable your app accepting all payment methods offered by Adyen. SDK provides UI components for payment method selection, entering payment details (credit card entry form, iDEAL issuer selection, and so on).

For quick integration, initiate `CheckoutViewController` and present it in your app:

```swift
var viewController: CheckoutViewController?

// ...

func presentCheckoutViewController() {
    viewController = CheckoutViewController(delegate: self)
    present(viewController!, animated: true, completion: nil)
}
```

After you implement the `CheckoutViewControllerDelegate` protocol, all UI interactions will be handled by SDK. Keeping a reference to the `CheckoutViewController` instance will ensure that delegate callbacks are received.


##### - checkoutViewController:requiresPaymentDataForToken:completion:


This method will be called first. It indicates that your app should obtain payment data from your server using the provided SDK `token`. Your server should make an API call to Adyen to initiate a payment request. The response from Adyen should be passed to SDK. For your convenience, we offer a test merchant server. Always use your own implementation when testing before going live.

Pass received payment data to SDK using `completion`. SDK will present the list of payment methods after you provide payment data.

```swift
func checkoutViewController(_ controller: CheckoutViewController, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {

   let paymentDetails: [String: Any] = [
      "basketId": "#237867422",
      "customerId": "user349857934",
      "appUrl": "my-shopping-app://", // Your App URI Scheme.
      "sdkToken": token   // Pass the `token` received from SDK.
   ]

   // For your convenience, we offer a test merchant server. Always use your own implementation when testing before going live.
   let url = URL(string: "https://shopper-test.adyen.com/demo/easy-integration/merchantserver/setup")!

   var request = URLRequest(url: url)
   request.httpMethod = "POST"
   request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
   request.allHTTPHeaderFields = [
      "X-MerchantServer-App-Id": "my-shopping-app",
     "X-MerchantServer-App-SecretKey": "06000100304F8D207D33F280549E06CDAE006BA186050F8E8CA79598A5C9558100027B7D",
     "Content-Type": "application/json"
   ]

   let session = URLSession(configuration: .default)
   session.dataTask(with: request) { data, response, error in
      if let data = data {
         completion(data)
      }
   }.resume()
}
```


##### - checkoutViewController:requiresReturnURL:


This method will be called if a selected payment method requires user authentication outside of your app environment (for example, in a web browser or native payment method app). After a user completes authorisation, your app will be opened using App URI Scheme. Use `completion` to provide SDK with the URL that was used to open your app.

```swift
func checkoutViewController(_ controller: CheckoutViewController, requiresReturnURL completion: @escaping URLCompletion) {
   // Call `completion` when you receive the app's `openURL`.
   let openURL =   //  Get the app's `openURL`.
   completion(openURL)
}
```


##### - checkoutViewController:didFinishWith:


Finally, you need to handle `result` for your payment request. You will get a payment object with the status (`authorised`, `refused`, etc.). Use this object to verify integrity of the payment with your server. Present the confirmation screen to the user to confirm the purchase.

```swift
func checkoutViewController(_ controller: CheckoutViewController, didFinishWith result: PaymentRequestResult) {
   // Handle the result.
   // ...
}
```


## Custom integration

It is possible to have more control over the payment flow — presenting your own UI for specific payment methods, filtering a list of payment methods, or implementing your own unique checkout experience.

For more control, start a payment request and implement the `PaymentRequestDelegate` protocol to get notified when your payment is authorized.

```swift
let request = PaymentRequest(delegate: self)
request.start()
```

After you implement the `PaymentRequestDelegate` protocol, you will have full control over the payment flow.

##### - paymentRequest:requiresPaymentDataForToken:completion:

This method will be called first. It indicates that your app should obtain payment data from your server using the provided SDK `token`. Your server should make an API call to Adyen to initiate a payment request. The response from Adyen should be passed to SDK. For your convenience, we offer a test merchant server. Always use your own implementation when testing before going live.

Pass received payment data to SDK using `completion`. In the next delegate call, SDK will provide the list of available payment methods for your payment request.

```swift
func paymentRequest(_ request: PaymentRequest, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {

   let paymentDetails: [String: Any] = [
      "basketId": "#237867422",
      "customerId": "user349857934",
      "appUrl": "my-shopping-app://", // Your App URI Scheme.
      "sdkToken": token   // Pass the `token` received from SDK.
   ]

   // For your convenience, we offer a test merchant server. Always use your own implementation when testing before going live.
   let url = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demo/easy-integration/merchantserver/setup")!

   var request = URLRequest(url: url)
   request.httpMethod = "POST"
   request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
   request.allHTTPHeaderFields = [
      "X-MerchantServer-App-Id": "my-shopping-app",
     "X-MerchantServer-App-SecretKey": "06000100304F8D207D33F280549E06CDAE006BA186050F8E8CA79598A5C9558100027B7D",
     "Content-Type": "application/json"
   ]

   let session = URLSession(configuration: .default)
   session.dataTask(with: request) { data, response, error in
      if let data = data {
         completion(data)
      }
   }.resume()
}
```

##### paymentRequest:requiresPaymentMethodFrom:availableMethods:completion:

This method will give you two lists of payment methods available for your payment request. `prefferedMethods` will contain `One-Click` enabled payment methods. Other payment options will be in the `availableMethods` list. 

Call `completion` with the selected payment method to indicate a shopper's choice.

```swift

func paymentRequest(_ request: PaymentRequest, requiresPaymentMethodFrom preferredMethods: [PaymentMethod]?, available availableMethods: [PaymentMethod], completion: @escaping MethodCompletion) {
   // Present the list of payment methods and call `completion` with a user's choice.
   // ...
}
```


##### paymentRequest:requiresReturnURLFrom:completion:

This method will be called if a selected payment method requires user authorisation outside of your app environment (for example, in a web browser or native payment method app). Use the provided `url` to start authorisation process. After a user completes authorisation, your app will be opened using App URI Scheme. Use `completion` to provide SDK with the URL that was used to open your app.

```swift
func paymentRequest(_ request: PaymentRequest, requiresReturnURLFrom url: URL, completion: @escaping URLCompletion) {
   // Open redirect URL (for example in `SFViewController`).
   // ...

   // Call `completion` when you receive the app's `openURL`.
   let openURL =   //  Get the app's `openURL`.
   completion(openURL)
}
```


##### paymentRequest:requiresPaymentDetails:completion:

This method will be called when additional payment details input is required for the specific payment method. SDK will give you a list of parameters required to provide. Get requested parameters from the user by presenting your own UI and pass them to SDK using `completion`.

```swift
func paymentRequest(_ request: PaymentRequest, requiresPaymentDetails details: PaymentDetails, completion: @escaping PaymentDetailsCompletion) {
   // Present payment details entry screen to the user.
   // ...

   // Pass received payment details to SDK.
   details.fill... // Get the user's input.
   completion(details)
}
```


##### - paymentRequest:didFinishWith:

Finally, you need to handle `result` for your payment request. You will get a payment object with the status (`authorized`, `refused`, etc.). Use this object to verify integrity of the payment with your server. Present confirmation screen to the user to confirm the purchase.

```swift
func paymentRequest(_ request: PaymentRequest, didFinishWith result: PaymentRequestResult) {
   // Handle the result.
   // ...
}
```


## License

This repository is open source and available under the MIT license. For more information, see the LICENSE file.
