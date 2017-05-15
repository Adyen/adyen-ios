# Adyen SDK for iOS
Want to add a checkout to your iOS app? No matter if your shopper wants to pay with a card (optionally with 3D Secure & one-click), wallet or a local payment method – all can be integrated in the same way, using the Adyen SDK. The Adyen SDK encrypts sensitive card data and sends it directly to Adyen, to keep your PCI scope limited.

This README provides the usage manual for the SDK itself. For the full documentation, including the server side implementation guidelines, refer to https://docs.adyen.com/developers/in-app-integration-guide.


## Installation
The Adyen SDK can be integrated easily into your project using CocoaPods. For this, add the following line to your Podfile and run `pod install`.

```
pod 'Adyen'
```

To give you as much flexibility as possible, our iOS SDK can be integrated in two ways:

* **Quick integration** – Benefit from the SDK out-of-the-box with a fully optimized UI
* **Custom integration** – Design your own UI while leveraging the underlying functionality of the SDK


## Quick integration
The Quick integration of the SDK provides the complete UI flow for payment method selection and entering payment details (credit card entry form, iDEAL issuer selection, and so on). To get started, initiate `CheckoutViewController` and present it in your app:

```swift
let viewController = CheckoutViewController(delegate: self)
present(viewController, animated: true, completion: nil)
```

After you implemented the `CheckoutViewControllerDelegate` protocol, all UI interactions will be handled by SDK.


#### - checkoutViewController:requiresPaymentDataForToken:completion:

This method will be called first. It indicates that your app should obtain payment data from your server using the provided SDK `token`. Your server should make an API call to Adyen to initiate a payment request. The response from Adyen should be passed to SDK. For your convenience, we offer a test merchant server. Always use your own implementation when testing before going Live.

Pass the received payment data to SDK using `completion`. The SDK will present the list of payment methods after you provide payment data.

```swift
func checkoutViewController(_ controller: CheckoutViewController, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {

   let paymentDetails: [String: Any] = [
      "basketId": "#237867422",
      "customerId": "user349857934",
      "appUrl": "my-shopping-app://", // Your App URI Scheme.
      "sdkToken": token   // Pass the `token` received from SDK.
   ]

   // For your convenience, we offer a test merchant server. Always use your own implementation when testing before going Live.
   let url = URL(string: "https://shopper-test.adyen.com/demo/easy-integration/merchantserver/setup")!

   var request = URLRequest(url: url)
   request.httpMethod = "POST"
   request.httpBody = try? JSONSerialization.data(withJSONObject: paymentDetails, options: [])
   request.allHTTPHeaderFields = [
      "X-MerchantServer-App-Id": "my-shopping-app", // Replace with your own app id
     "X-MerchantServer-App-SecretKey": "06000100304F8D207D33F280549E06CDAE006BA186050F8E8CA79598A5C9558100027B7D", // Replace with your own secret key
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


#### - checkoutViewController:requiresReturnURL:

This method will be called if a selected payment method requires user authentication outside of your app environment (for example, in web browser or native payment method app). After a user completes authorization, your app will be opened using App URI Scheme. Use `completion` to provide SDK with the URL that was used to open your app.

```swift
func checkoutViewController(_ controller: CheckoutViewController, requiresReturnURL completion: @escaping URLCompletion) {
   // Call `completion` when you receive the app's `openURL`.
   let openURL =   //  Get app's `openURL`.
   completion(openURL)
}
```


#### - checkoutViewController:didFinishWith:

Finally, you need to handle `result` for your payment request. You will get a payment object with the status (`authorized`, `refused`, etc.). Use this object to verify integrity of the payment with your server. Present confirmation screen to the user to confirm the purchase.

```swift
func checkoutViewController(_ controller: CheckoutViewController, didFinishWith result: PaymentRequestResult) {
   // Handle the result.
   // ...
}
```


## Custom integration

It is possible to have more control over the payment flow — presenting your own UI for specific payment methods, filtering a list of payment methods, or implementing your own unique checkout experience.

For more control, just start a payment request and implement the `PaymentRequestDelegate` protocol to get notified when your payment is authorized.

```swift
let request = PaymentRequest(delegate: self)
request.start()
```

After you implement `PaymentRequestDelegate` protocol, you will have full control over the payment flow.


#### - paymentRequest:requiresPaymentDataForToken:completion:

This method will be called first. It indicates that your app should obtain payment data from your server using provided SDK `token`. Your server should make an API call to Adyen to initiate a payment request. The response from Adyen should be passed to SDK. For your convenience, we offer a test merchant server. Always use your own implementation when testing before going Live.

Pass received payment data to SDK using `completion`. In the next delegate call, SDK will provide the list of available payment methods for your payment request.

```swift
func paymentRequest(_ request: PaymentRequest, requiresPaymentDataForToken token: String, completion: @escaping DataCompletion) {

   let paymentDetails: [String: Any] = [
      "basketId": "#237867422",
      "customerId": "user349857934",
      "appUrl": "my-shopping-app://", // Your App URI Scheme.
      "sdkToken": token   // Pass the `token` received from SDK.
   ]

   // For your convenience, we offer a test merchant server. Always use your own implementation when testing before going Live.
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


#### paymentRequest:requiresPaymentMethodFrom:availableMethods:completion:

This method will give you two lists of payment methods available for your payment request. `prefferedMethods` will contain `One-Click` enabled payment methods. Other payment options will be in the `availableMethods` list. Call `completion` with the selected payment method to indicate a shopper's choice.

```swift

func paymentRequest(_ request: PaymentRequest, requiresPaymentMethodFrom preferredMethods: [PaymentMethod]?, available availableMethods: [PaymentMethod], completion: @escaping MethodCompletion) {
   // Present the list of payment methods and call `completion` with a user's choice.
   // ...
}
```


#### paymentRequest:requiresReturnURLFrom:completion:

This method will be called if a selected payment method requires user authorization outside of your app environment (for example, in web browser or native payment method app). Use the provided `url` to start authorization process. After a user completes authorization, your app will be opened using App URI Scheme. Use `completion` to provide SDK with the URL that was used to open your app.

```swift
func paymentRequest(_ request: PaymentRequest, requiresReturnURLFrom url: URL, completion: @escaping URLCompletion) {
   // Open redirect URL (for example in `SFViewController`).
   // ...

   // Call `completion` when you receive the app's `openURL`.
   let openURL =   //  Get the app's `openURL`.
   completion(openURL)
}
```


#### paymentRequest:requiresPaymentDetails:completion:

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


#### - paymentRequest:didFinishWith:

Finally, you need to handle `result` for your payment request. You will get a payment object with the status (`authorized`, `refused`, etc.). Use this object to verify integrity of the payment with your server. Present confirmation screen to the user to confirm the purchase.

```swift
func paymentRequest(_ request: PaymentRequest, didFinishWith result: PaymentRequestResult) {
   // Handle the result.
   // ...
}
```


## License

This repository is open source and available under the MIT license. For more information, see the LICENSE file.
