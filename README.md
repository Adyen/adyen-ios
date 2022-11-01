![GitHub Workflow Status](https://img.shields.io/github/workflow/status/adyen/adyen-ios/Build%20and%20Test)
[![Pod](https://img.shields.io/cocoapods/v/Adyen.svg?style=flat)](http://cocoapods.org/pods/Adyen)
[![carthage compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SwiftPM](https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg)](https://swiftpackageregistry.com/Adyen/adyen-ios)
[![codecov](https://codecov.io/gh/Adyen/adyen-ios/branch/develop/graph/badge.svg)](https://codecov.io/gh/Adyen/adyen-ios)

[![Sonarcloud Status](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=alert_status)](https://sonarcloud.io/dashboard?id=Adyen_adyen-ios)
[![SonarCloud Bugs](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=bugs)](https://sonarcloud.io/component_measures/metric/reliability_rating/list?id=Adyen_adyen-ios)
[![SonarCloud Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=vulnerabilities)](https://sonarcloud.io/component_measures/metric/security_rating/list?id=Adyen_adyen-ios)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=Adyen_adyen-ios)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=reliability_rating)](https://sonarcloud.io/dashboard?id=Adyen_adyen-ios)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=security_rating)](https://sonarcloud.io/dashboard?id=Adyen_adyen-ios)

<br/>

![iOS Logo](https://user-images.githubusercontent.com/2648655/198585678-047a1f5c-1463-4837-90b7-01e8094c9830.png)


# Adyen iOS

Adyen iOS provides you with the building blocks to create a checkout experience for your shoppers, allowing them to pay using the payment method of their choice.

You can integrate with Adyen iOS in two ways:
* [iOS Drop-in](https://docs.adyen.com/online-payments/ios/drop-in): an all-in-one solution, the quickest way to accept payments on your iOS app.
* [iOS Components](https://docs.adyen.com/online-payments/ios/components): one Component per payment method and combine with your own payments flow.


## Installation

Adyen iOS are available through either [CocoaPods](http://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage) or [Swift Package Manager](https://swift.org/package-manager/).

### CocoaPods

1. Add `pod 'Adyen'` to your `Podfile`.
2. Run `pod install`.

You can install all modules or add individual modules, depending on your needs and integration type.
The `Adyen/WeChatPay` module needs to be explicitly added to support WeChat Pay.
The `Adyen/SwiftUI` module needs to be explicitly added to use the SwiftUI specific helpers.

```
pod 'Adyen'               // Add DropIn with all modules except WeChat Pay and SwiftUI.
// Add individual modules
pod 'Adyen/Card'          // Card components.
pod 'Adyen/Session'       // Handler for the simplified checkout flow.
pod 'Adyen/Encryption'    // Encryption module.
pod 'Adyen/Components'    // All other payment components except WeChat Pay.
pod 'Adyen/Actions'       // Action Components.
pod 'Adyen/WeChatPay'     // WeChat Pay Component.
pod 'Adyen/SwiftUI'       // SwiftUI apps specific module.
```

:warning: _`Adyen/AdyenWeChatPay` and `AdyenWeChatPayInternal` modules doesn't support any simulators and can only be tested on a real device._

### Carthage

1. Add `github "adyen/adyen-ios"` to your `Cartfile`.
2. Run `carthage update`.
3. Link the framework with your target as described in [Carthage Readme](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

You can add all modules or select individual modules to add to your integration. But make sure to include each module dependency modules.

* `AdyenDropIn`: DropInComponent.
* `AdyenSession`: handler for the simplified checkout flow.
* `AdyenCard`: the card components.
* `AdyenComponents`: all other payment components except WeChat Pay.
* `AdyenActions`:  action components.
* `AdyenEncryption`: encryption.
* `AdyenWeChatPay`: WeChat Pay component.
* `AdyenWeChatPayInternal`: WeChat Pay component.
* `AdyenSwiftUI`: SwiftUI apps specific module.

:warning: _`AdyenWeChatPay` and `AdyenWeChatPayInternal` modules doesn't support any simulators and can only be tested on a real device._

### Swift Package Manager

1. Follow Apple's [Adding Package Dependencies to Your App](
https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app
) guide on how to add a Swift Package dependency.
2. Use `https://github.com/Adyen/adyen-ios` as the repository URL.
3. Specify the version to be at least `3.8.0`.

You can add all modules or select individual modules to add to your integration.
The `AdyenWeChatPay` module needs to be explicitly added to support WeChat Pay.
The `AdyenSwiftUI` module needs to be explicitly added to use the SwiftUI specific helpers.

* `AdyenDropIn`: all modules except `AdyenWeChatPay`.
* `AdyenSession`: handler for the simplified checkout flow.
* `AdyenCard`: the card components.
* `AdyenComponents`: all other payment components except WeChat Pay.
* `AdyenActions`:  action components.
* `AdyenEncryption`: encryption.
* `AdyenWeChatPay`: WeChat Pay component.
* `AdyenSwiftUI`: SwiftUI apps specific module.

:warning: _Please make sure to use Xcode 12.0+ when adding `Adyen` using Swift Package Manager._

:warning: _Swift Package Manager for Xcode 12.0 and 12.1 has a [know issue](https://bugs.swift.org/browse/SR-13343) when it comes to importing a dependency that in turn depend on a binary dependencies. A workaround is described [here](https://forums.swift.org/t/swiftpm-binarytarget-dependency-and-code-signing/38953)._

:warning: _`AdyenWeChatPay` and `AdyenWeChatPayInternal` modules doesn't support any simulators and can only be tested on a real device._

## Drop-in

The [Drop-in](https://adyen.github.io/adyen-ios/Docs/Classes/DropInComponent.html) handles the presentation of available payment methods and the subsequent entry of a customer's payment details. It is initialized with the response of [`/sessions`][apiExplorer.sessions], and handles the entire checkout flow under the hood.

### Usage

#### Setting up the Drop-in

All Components need an `AdyenContext`. An instance of `AdyenContext` wraps your client key, environment, analytics configuration and so on.
Please read more [here](https://docs.adyen.com/development-resources/client-side-authentication) about the client key and how to get one.
Use **Environment.test** for environment. When you're ready to accept live payments, change the value to one of our [live environments](https://adyen.github.io/adyen-ios/Docs/Structs/Environment.html)

```swift
let apiContext = APIContext(clientKey: clientKey, environment: Environment.test)
let context = AdyenContext(apiContext: apiContext, analyticsConfiguration: analyticsConfiguration)
let configuration = DropInComponent.Configuration(context: context)
```

Create an instance of `AdyenSession.Configuration` with the response you received from the `/sessions` call and the `AdyenContext` instance.

```swift
let configuration = AdyenSession.Configuration(sessionIdentifier: response.sessionId,
                                               initialSessionData: response.sessionData,
                                               context: context)
```

Call the static `initialize` function of the `AdyenSession` by providing the configuration and the delegates, which will asynchronously create and return the session instance.

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

Create a configuration object for `DropInComponent`. Check specific payment method pages to confirm if you need to include additional required parameters.

```swift
// Check specific payment method pages to confirm if you need to configure additional required parameters.
let dropInConfiguration = DropInComponent.Configuration(context: context)

```

Some payment methods need additional configuration. For example `ApplePayComponent`. These payment method specific configuration parameters can be set in an instance of `DropInComponent.Configuration`:

```swift
let summaryItems = [
                      PKPaymentSummaryItem(label: "Item A", amount: 75, type: .final),
                      PKPaymentSummaryItem(label: "Item B", amount: 25, type: .final),
                      PKPaymentSummaryItem(label: "My Company", amount: 100, type: .final)
                   ]
let applePayment = try ApplePayPayment(countryCode: "US",
                                       currencyCode: "USD",
                                       summaryItems: summaryItems)

let dropInConfiguration = DropInComponent.Configuration(context: context)
dropInConfiguration.applePay = .init(payment: applePayment,
                               merchantIdentifier: "merchant.com.adyen.MY_MERCHANT_ID")
```

Also for voucher payment methods like Doku variants, in order for the `DokuComponent` to enable the shopper to save the voucher, access to the shopper photos is requested, so a suitable text needs to be added to the `NSPhotoLibraryAddUsageDescription` key in the application `Info.plist`.

#### Presenting the Drop-in

Initialize the `DropInComponent` class and set the `AdyenSession` instance as the `delegate` and `partialPaymentDelegate` (if needed) of the `DropInComponent` instance.

```swift
let dropInComponent = DropInComponent(paymentMethods: session.sessionContext.paymentMethods,
                                     configuration: dropInConfiguration)
 
// Keep the Drop-in instance to avoid it being destroyed after the function is executed.
self.dropInComponent = dropInComponent
 
// Set session as the delegate for Drop-in
dropInComponent.delegate = session
dropInComponent.partialPaymentDelegate = session
 
present(dropInComponent.viewController, animated: true)

```

#### Implementing `AdyenSessionDelegate`

`AdyenSession` makes the necessary calls to handle the whole flow and notifies your application through its delegate, `AdyenSessionDelegate`. To handle the results of the Drop-in, the following methods of `AdyenSessionDelegate` should be implemented:

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

#### Handling an action

Actions are handled by the Drop-in via its delegate `AdyenSession`.


##### Receiving redirect

In case the customer is redirected to an external URL or App, make sure to let the `RedirectComponent` know when the user returns to your app. Do this by implementing the following in your `UIApplicationDelegate`:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
    RedirectComponent.applicationDidOpen(from: url)

    return true
}
```

## Components

In order to have more flexibility over the checkout flow, you can use our Components to present each payment method individually. Implementation details of our Components can be found in our [Components API Reference][reference].

### Available Components

- [Card Component][reference.cardComponent]
- [3D Secure 2 Component][reference.threeDS2Component]
- [Apple Pay Component][reference.applePayComponent]
- [BCMC Component][reference.bcmcComponent]
- [iDEAL Component][reference.issuerListComponent]
- [SEPA Direct Debit Component][reference.sepaDirectDebitComponent]
- [MOLPay Component][reference.issuerListComponent]
- [Dotpay Component][reference.issuerListComponent]
- [EPS Component][reference.issuerListComponent]
- [Entercash Component][reference.issuerListComponent]
- [Open Banking Component][reference.issuerListComponent]
- [WeChat Pay Component][reference.weChatPaySDKActionComponent]
- [Qiwi Wallet Component][reference.qiwiWalletComponent]
- [Redirect Component][reference.redirectComponent]
- [MB Way Component][reference.mbWayComponent]
- [BLIK Component][reference.BLIKComponent]
- [Doku Component][reference.DokuComponent]
- [Boleto Component][reference.BoletoComponent]
- [ACH Direct Debit Component][reference.ACHDirectDebitComponent]
- [Affirm Component][reference.AffirmComponent]
- [Atome Component][reference.AtomeComponent]
- [BACS Direct Debit Component][reference.BACSDirectDebitComponent]
- [Online Banking Czech republic Component][reference.OnlineBankingComponent]
- [Online Banking Slovakia Component][reference.OnlineBankingComponent]
- [Online Banking Poland Component][reference.issuerListComponent]


## Customization

Both the Drop-in and the Components offer a number of customization options to allow you to match the appearance of your app.
For example, to change the section header titles and form field titles in the Drop-in to red, and turn the submit button's background to black with white foreground:
```swift
var style = DropInComponent.Style()
style.listComponent.sectionHeader.title.color = .red
style.formComponent.textField.title.color = .red
style.formComponent.mainButtonItem.button.backgroundColor = .black
style.formComponent.mainButtonItem.button.title.color = .white

let dropInComponent = DropInComponent(paymentMethods: paymentMethods,
                                      configuration: configuration,
                                      style: style)
dropInComponent.delegate = self.session
```

Or, to create a black Card Component with white text:
```swift
var style = FormComponentStyle()
style.backgroundColor = .black
style.header.title.color = .white
style.textField.title.color = .white
style.textField.text.color = .white
style.switch.title.color = .white

let component = CardComponent(paymentMethod: paymentMethod,
                              apiContext: context.apiContext,
                              style: style)
component.delegate = self.session
```

A full list of customization options can be found in the [API Reference][reference.styles].

## Requirements

- iOS 11.0+
- Xcode 11.0+
- Swift 5.1

## See also

* [Complete Documentation](https://docs.adyen.com/developers/checkout/ios)

* [Components API Reference](https://adyen.github.io/adyen-ios/Docs/index.html)

## Support

If you have a feature request, or spotted a bug or a technical problem, create a GitHub issue. For other questions, contact our [support team](https://support.adyen.com/hc/en-us/requests/new?ticket_form_id=360000705420).

## Contributing
We strongly encourage you to join us in contributing to this repository so everyone can benefit from:
* New features and functionality
* Resolved bug fixes and issues
* Any general improvements


Read our [**contribution guidelines**](CONTRIBUTING.md) to find out how.

## License

This repository is open source and available under the MIT license. For more information, see the LICENSE file.

[reference]: https://adyen.github.io/adyen-ios/Docs/index.html
[reference.dropInComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/DropInComponent.html
[reference.cardComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/CardComponent.html
[reference.threeDS2Component]: https://adyen.github.io/adyen-ios/Docs/Classes/ThreeDS2Component.html
[reference.applePayComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/ApplePayComponent.html
[reference.bcmcComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/BCMCComponent.html
[reference.issuerListComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/IssuerListComponent.html
[reference.weChatPaySDKActionComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/WeChatPaySDKActionComponent.html
[reference.qiwiWalletComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/QiwiWalletComponent.html
[reference.sepaDirectDebitComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/SEPADirectDebitComponent.html
[reference.redirectComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/RedirectComponent.html
[reference.mbWayComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/MBWayComponent.html
[reference.BLIKComponent]: https://adyen.github.io/adyen-ios/Docs/Classes/BLIKComponent.html
[reference.DokuComponent]:  https://adyen.github.io/adyen-ios/Docs/Classes/DokuComponent.html
[reference.BoletoComponent]:  https://adyen.github.io/adyen-ios/Docs/Classes/BoletoComponent.html
[reference.ACHDirectDebitComponent]:  https://adyen.github.io/adyen-ios/Docs/Classes/ACHDirectDebitComponent.html
[reference.AffirmComponent]:  https://adyen.github.io/adyen-ios/Docs/Classes/AffirmComponent.html
[reference.BACSDirectDebitComponent]:  https://adyen.github.io/adyen-ios/Docs/Classes/BACSDirectDebitComponent.html
[reference.AtomeComponent]:  https://adyen.github.io/adyen-ios/Docs/Classes/AtomeComponent.html
[reference.styles]: https://adyen.github.io/adyen-ios/Docs/Styling.html
[apiExplorer.sessions]: https://docs.adyen.com/api-explorer/#/CheckoutService/latest/post/sessions
