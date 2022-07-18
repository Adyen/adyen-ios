# DropIn

The Drop-in handles the presentation of available payment methods and the subsequent entry of a customer's payment details. It is initialized with the payment methods of the `/sessions` response, and handles the entire checkout flow under the hood for most of use cases.

If the simplified checkout flow with the `/sessions` endpoint does not work for you, or you prefer to have more control over the whole flow, please refer to [**implementation via the three endpoints**](DropInThreeAPIs.md).

## Setting up the Drop-in

All Components need an ``AdyenContext``. An instance of ``AdyenContext`` wraps your client key, environment, payment, analytics configuration and so on.
Please read more [here](https://docs.adyen.com/development-resources/client-side-authentication) about the client key and how to get one.
Use **Environment.test** for environment. When you're ready to accept live payments, change the value to one of our [live environments](https://adyen.github.io/adyen-ios/Docs/Structs/Environment.html).
We recommend creating a new context for each payment attempt.

```swift
var context: AdyenContext {
    let apiContext = APIContext(clientKey: clientKey, environment: Environment.test)
    return AdyenContext(apiContext: apiContext,
                        payment: payment,
                        analyticsConfiguration: analyticsConfiguration)
}
```

Create an instance of `AdyenSession.Configuration` with the response you received from the `/sessions` call and the ``AdyenContext`` instance.

```swift
let configuration = AdyenSession.Configuration(sessionIdentifier: response.sessionId,
                                               initialSessionData: response.sessionData,
                                               context: context)
```

Call the static `initialize` function of the ``AdyenSession`` by providing the configuration and the delegates, which will asynchronously create and return the session instance.

```swift
AdyenSession.initialize(with: configuration, delegate: self, presentationDelegate: self) { [weak self] result in
    switch result {
    case let .success(session):
        // store the session object
        self?.session = session
    case let .failure(error):
        // handle the error
    }
}
```

Create a configuration object for ``DropInComponent``. Check specific payment method pages to confirm if you need to include additional required parameters.

```swift
// Check specific payment method pages to confirm if you need to configure additional required parameters.
let dropInConfiguration = DropInComponent.Configuration()
let component = DropInComponent(paymentMethods: paymentMethods,
                                context: context,
                                configuration: dropInConfiguration)

```

Some payment methods need additional configuration. For example ``ApplePayComponent``. These payment method specific configuration parameters can be set in an instance of ``DropInComponent.Configuration``:

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

Also for voucher payment methods like Doku variants, in order for the ``DokuComponent`` to enable the shopper to save the voucher, access to the shopper photos is requested, so a suitable text needs to be added to the `NSPhotoLibraryAddUsageDescription` key in the application `Info.plist`.

## Presenting the Drop-in

Initialize the ``DropInComponent`` class and set the ``AdyenSession`` instance as the `delegate` and `partialPaymentDelegate` (if needed) of the ``DropInComponent`` instance.

```swift
let dropInComponent = DropInComponent(paymentMethods: paymentMethods,
                                      context: context,
                                      configuration: dropInConfiguration)
 
// Keep the Drop-in instance to avoid it being destroyed after the function is executed.
self.dropInComponent = dropInComponent
 
// Set session as the delegate for Drop-in
dropInComponent.delegate = session
dropInComponent.partialPaymentDelegate = session
 
present(dropInComponent.viewController, animated: true)

```

### Implementing `AdyenSessionDelegate`

``AdyenSession`` makes the necessary calls to handle the whole flow and notifies your application through its delegate, ``AdyenSessionDelegate``. To handle the results of the Drop-in, the following methods of ``AdyenSessionDelegate`` should be implemented:

---

```swift
func didComplete(with resultCode: SessionPaymentResultCode, component: Component, session: AdyenSession)
```

This method will be invoked when the component finishes without any further steps needed by the application. The application just needs to dismiss the current component, ideally after calling `finalizeIfNeeded` on the component.

---

```swift
func didFail(with error: Error, from component: Component, session: AdyenSession)
```

This method is invoked when an error occurred during the use of the Drop-in or the components.
You can then call the `finalizeIfNeeded` on the component, dismiss the component's view controller in the completion callback and display an error message.

---

```swift
func didOpenExternalApplication(component: DropInComponent)
```

This optional method is invoked after a redirect to an external application has occurred.

---

## Handling an action

Actions are handled by the Drop-in via its delegate ``AdyenSession``.


### Receiving redirect

In case the customer is redirected to an external URL or App, make sure to let the ``RedirectComponent`` know when the user returns to your app. Do this by implementing the following in your `UIApplicationDelegate`:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
    RedirectComponent.applicationDidOpen(from: url)
    return true
}
```
