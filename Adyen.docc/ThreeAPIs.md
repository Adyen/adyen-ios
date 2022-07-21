
# Three API Approach

If the simplified checkout flow starting with the `/sesssions` call does not work for your needs,
you can opt-in to use the previously default approach, that starts with the `/paymentMethods` API call.
In contrast to the simplified flow, your server will need to make two additional API calls, namely the
`/payments` and `/payments/details` calls when needed.

The Drop-in is initialized with the response of `/paymentMethods`, and provides everything you need to make an API call to `/payments` and `/payments/details`.

## Presenting the Drop-in

The Drop-in requires the response of the `/paymentMethods` endpoint to be initialized. To pass the response to Drop-in, decode the response to the `PaymentMethods` structure:

```swift
let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: response)
```

All Components need an ``APIContext``. An instance of `APIContext` wraps your client key and an environment.
Please read more [here](https://docs.adyen.com/development-resources/client-side-authentication) about the client key and how to get.
Use **Environment.test** for environment. When you're ready to accept live payments, change the value to one of our [live environments](https://adyen.github.io/adyen-ios/Docs/Structs/Environment.html)
We recommend creating a new context for each payment attempt.

```swift
var context: AdyenContext {
    let apiContext = APIContext(clientKey: clientKey, environment: Environment.test)
    return AdyenContext(apiContext: apiContext,
                        payment: payment,
                        analyticsConfiguration: analyticsConfiguration)
}
```

Some payment methods need additional configuration. For example ``ApplePayComponent``. These payment method specific configuration parameters can be set in an instance of `DropInComponent.Configuration`:

```swift
let summaryItems = [
                      PKPaymentSummaryItem(label: "Item A", amount: 75, type: .final),
                      PKPaymentSummaryItem(label: "Item B", amount: 25, type: .final),
                      PKPaymentSummaryItem(label: "My Company", amount: 100, type: .final)
                   ]
let applePayment = try ApplePayPayment(countryCode: "US",
                                       currencyCode: "USD",
                                       summaryItems: summaryItems)

let dropInConfiguration = DropInComponent.Configuration()
dropInConfiguration.applePay = .init(payment: applePayment,
                                     merchantIdentifier: "merchant.com.adyen.MY_MERCHANT_ID")
```

Also for voucher payment methods like Doku variants, in order for the ``DokuComponent`` to enable the shopper to save the voucher, access to the shopper photos is requested, so a suitable text need to be added to key  `NSPhotoLibraryAddUsageDescription` in the application Info.plist.

After serializing the payment methods and creating the configuration, the Drop-in is ready to be initialized. Assign a `delegate` and use the `viewController` property to present the Drop-in on the screen:

```swift
let dropInComponent = DropInComponent(paymentMethods: paymentMethods,
                                      context: context,
                                      configuration: dropInConfiguration)

self.dropInComponent = dropInComponent
dropInComponent.delegate = self
present(dropInComponent.viewController, animated: true)
```
### Implementing DropInComponentDelegate

To handle the results of the Drop-in, the following methods of ``DropInComponentDelegate`` should be implemented:

---

```swift
func didSubmit(_ data: PaymentComponentData, for paymentMethod: PaymentMethod, from component: DropInComponent)
```

This method is invoked when the customer has selected a payment method and entered its payment details. The payment details can be read from `data.paymentMethod` and can be submitted as-is to `/payments`.

---

```swift
func didProvide(_ data: ActionComponentData, from component: DropInComponent)
```

This method is invoked when additional details are provided by the Drop-in after the first call to `/payments`. This happens, for example, during the 3D Secure 2 authentication flow or any redirect flow. The additional details can be retrieved from `data.details` and can be submitted to `/payments/details`.

---

```swift
func didFail(with error: Error, from component: DropInComponent)
```

This method is invoked when an error occurred during the use of the Drop-in. Dismiss the Drop-in's view controller and display an error message.

---

```swift
func didComplete(from component: DropInComponent)
```

This method is invoked when the action component finishes, without any further steps needed by the application, for example in case of voucher payment methods. The application just needs to dismiss the ``DropInComponent``.

---

```swift
func didCancel(component: PaymentComponent, from dropInComponent: DropInComponent)
```

This optional method is invoked when user closes a payment component managed by Drop-in.

---

```swift
func didOpenExternalApplication(component: DropInComponent)
```

This optional method is invoked after a redirect to an external application has occurred.

---

## Handling an action

When `/payments` or `/payments/details` responds with a non-final result and an `action`, you can use one of the following techniques.

### Using Drop-in

In case of Drop-in integration you must use build-in action handler on the current instance of ``DropInComponent``:

```swift
let action = try JSONDecoder().decode(Action.self, from: actionData)
dropInComponent.handle(action)
```

### Using components

In case of using individual components, create and persist an instance of ``AdyenActionComponent``:

```swift
lazy var actionComponent: AdyenActionComponent = {
    let handler = AdyenActionComponent(context: context)
    handler.delegate = self
    handler.presentationDelegate = self
    return handler
}()
```

Than use it to handle the action:

```swift
let action = try JSONDecoder().decode(Action.self, from: actionData)
actionComponent.handle(action)
```

## Receiving redirect

In case the customer is redirected to an external URL or App, make sure to let the ``RedirectComponent`` know when the user returns to your app. Do this by implementing the following in your `UIApplicationDelegate`:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
    RedirectComponent.applicationDidOpen(from: url)

    return true
}
```
