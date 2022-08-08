# Components

In order to have more flexibility over the checkout flow, you can use our Components to present each payment method individually. Implementation details of our Components can be found in our Components API Reference.

## Available Components

- ``CardComponent``
- ``ThreeDS2Component``
- ``ApplePayComponent``
- ``BCMCComponent``
- ``IssuerListComponent``
- ``MOLPayComponent``
- ``DotpayComponent``
- ``EPSComponent``
- ``EntercashComponent``
- ``OpenBankingComponent``
- ``SEPADirectDebitComponent``
- ``WeChatPaySDKActionComponent``
- ``QiwiWalletComponent``
- ``RedirectComponent``
- ``MBWayComponent``
- ``BLIKComponent``
- ``DokuComponent``
- ``BoletoComponent``
- ``ACHDirectDebitComponent``
- ``AffirmComponent``
- ``AtomeComponent``
- ``BACSDirectDebitComponent``
- ``OnlineBankingComponent``

## Setting up the Component

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

Create an instance of ``AdyenSession.Configuration`` with the response you received from the `/sessions` call and the ``AdyenContext`` instance.

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

Fetch `paymentMethod` from `session.sessionContext.paymentMethods` response or create one manually.

```swift
guard let paymentMethods = self.session?.sessionContext.paymentMethods,
      let paymentMethod = paymentMethods.paymentMethod(ofType: CardPaymentMethod.self) else { return nil }
```

You can configure your component by providing `Configuration` object.
Check specific payment method pages to confirm if you need to include additional required parameters.

```swift
let style = FormComponentStyle()
let configuration = CardComponent.Configuration(style: style)
configuration.showsHolderNameField = true
return CardComponent(paymentMethod: paymentMethod,
                     context: context,
                     configuration: configuration)
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
                                       
var config = ApplePayComponent.Configuration(payment: applePayPayment,
                                             merchantIdentifier: "merchant.com.adyen.MY_MERCHANT_ID")

return try? ApplePayComponent(paymentMethod: paymentMethod,
                              context: context,
                              configuration: config)
```

Also for voucher payment methods like Doku variants, in order for the ``DokuComponent`` to enable the shopper to save the voucher, access to the shopper photos is requested, so a suitable text needs to be added to the `NSPhotoLibraryAddUsageDescription` key in the application `Info.plist`.

## Presenting the component

Initialize a choosen component class and set the ``AdyenSession`` instance as the `delegate` and `partialPaymentDelegate` (if needed) of the component instance.
Some components designed to be embedded into another `UIViewContolller` (ex. `UINavigationController`); others must be presented "as-is".

```swift
private func present(component: PresentableComponent) {
    if let paymentComponent = component as? PaymentComponent {
        paymentComponent.delegate = sessions
    }

    // Keep the component instance to avoid it being destroyed after the function is executed.
    self.component = component

    // Check if component can be presented as is or needs extra navigation layer.
    guard component.requiresModalPresentation else {
        presenter?.present(viewController: component.viewController, completion: nil)
        return
    }

    let navigation = UINavigationController(rootViewController: component.viewController)
    component.viewController.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .cancel,
                                                                       target: self,
                                                                       action: #selector(cancelPressed))
    present(navigation, animated: true, completion: nil)
}
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

This method is invoked when an error occurred during the use of the components.
You can then call the `finalizeIfNeeded` on the component, dismiss the component's view controller in the completion callback and display an error message.

---

```swift
func didOpenExternalApplication(component: ActionComponent)
```

This optional method is invoked after a redirect to an external application has occurred.

---

## Handling an action

Actions are handled by the ``AdyenSession``.


### Receiving redirect

In case the customer is redirected to an external URL or App, make sure to let the ``RedirectComponent`` know when the user returns to your app. Do this by implementing the following in your `UIApplicationDelegate`:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
    RedirectComponent.applicationDidOpen(from: url)
    return true
}
```
