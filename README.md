![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/adyen/adyen-ios/verify-os-compatibility.yml?branch=develop)
[![Pod](https://img.shields.io/cocoapods/v/Adyen.svg?style=flat)](http://cocoapods.org/pods/Adyen)
[![SwiftPM](https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg)](https://swiftpackageregistry.com/Adyen/adyen-ios)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=coverage)](https://sonarcloud.io/component_measures?metric=coverage&id=Adyen_adyen-ios)

[![Sonarcloud Status](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=alert_status)](https://sonarcloud.io/dashboard?id=Adyen_adyen-ios)
[![SonarCloud Bugs](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=bugs)](https://sonarcloud.io/component_measures/metric/reliability_rating/list?id=Adyen_adyen-ios)
[![SonarCloud Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=vulnerabilities)](https://sonarcloud.io/component_measures/metric/security_rating/list?id=Adyen_adyen-ios)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=Adyen_adyen-ios)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=reliability_rating)](https://sonarcloud.io/dashboard?id=Adyen_adyen-ios)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=Adyen_adyen-ios&metric=security_rating)](https://sonarcloud.io/dashboard?id=Adyen_adyen-ios)

[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAdyen%2Fadyen-ios%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Adyen/adyen-ios)
[![Supported Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAdyen%2Fadyen-ios%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Adyen/adyen-ios)
<br/>

![iOS Logo](https://user-images.githubusercontent.com/2648655/198585678-047a1f5c-1463-4837-90b7-01e8094c9830.png)


# Adyen iOS

> ### :rotating_light: Are you integrating with v5?
>
> This branch documents **v6**, which is currently in **alpha** and under active development. Its public API can still change, and the v5 API is not available here.
>
> For the latest stable release, use the [**`v5` branch**][branch.v5] and the [v5 integration guides](https://docs.adyen.com/online-payments/build-your-integration/?platform=iOS).

Adyen iOS provides you with the building blocks to create a checkout experience for your shoppers, allowing them to pay using the payment method of their choice.

The v6 alpha integrates with [iOS Components](https://docs.adyen.com/online-payments/build-your-integration/?platform=iOS&integration=Components): one Component per payment method, combined with your own payments flow. [iOS Drop-in](https://docs.adyen.com/online-payments/build-your-integration/?platform=iOS&integration=Drop-in), the all-in-one solution, is not available in the v6 alpha yet.

## SDK lifecycle

| Major version | State                  | Deprecated    | End-of-life   |
|---------------|------------------------|---------------|---------------|
| 6.x.x         | Alpha (in development) | ---           | ---           |
| 5.x.x         | Active                 | ---           | ---           |
| 4.x.x         | Inactive               | December 2026 | December 2027 |
| 3.x.x         | End-of-life            | November 2021 | November 2022 |

More information about our versioning and the Drop-in/Components lifecycle can be found [here](https://docs.adyen.com/online-payments/upgrade-your-integration/).

## v6 alpha documentation

The v6 API documented in this branch is currently alpha. These guides describe the current public v6 API.

* [v6 foundations][docs.github.v6.readme]
* [v6 card component overview][docs.github.v6.card]
* [v6 card component: session flow][docs.github.v6.cardSession]
* [v6 card component: advanced flow][docs.github.v6.cardAdvanced]
* [v6 checkout theme][docs.github.v6.theme]
* [v5 to v6 migration notes][docs.github.v6.migration]

## Installation

Adyen iOS is available through either [CocoaPods](http://cocoapods.org) or [Swift Package Manager](https://swift.org/package-manager/).

### Minimum Requirements

- iOS 16.0
- Xcode 15.0
- Swift 5.9

### Swift Package Manager

1. Follow Apple's [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) guide on how to add a Swift Package dependency.
2. Use `https://github.com/Adyen/adyen-ios` as the repository URL.
3. Specify the version to be at least `6.0.0-alpha.1`.

You can add all modules or select individual modules to add to your integration.
The `AdyenWeChatPay` module needs to be explicitly added to support WeChat Pay.
The `AdyenTwint` module needs to be explicitly added to support Twint native flow.
The `AdyenSwiftUI` module needs to be explicitly added to use the SwiftUI specific helpers.

* `AdyenCheckout`: the v6 entry point, includes `Adyen`, `AdyenCard`, `AdyenComponents`, `AdyenActions` and `AdyenSession`.
* `Adyen`: core module.
* `AdyenUI`: shared UI, form items and theming.
* `AdyenCard`: the card components.
* `AdyenComponents`: all other payment components except WeChat Pay.
* `AdyenActions`:  action components.
* `AdyenEncryption`: encryption.
* `AdyenSession`: handler for the simplified checkout flow.
* `AdyenCardScanner`: card scanning support.
* `AdyenWeChatPay`: WeChat Pay component.
* `AdyenTwint`: Twint component.
* `AdyenCashAppPay`: Cash App Pay component.
* `AdyenSwiftUI`: SwiftUI apps specific module.

:warning: _`AdyenWeChatPay` and `AdyenWeChatPayInternal` modules don't support any simulators and can only be tested on a real device._

### CocoaPods

1. Add `pod 'Adyen'` to your `Podfile`.
2. Run `pod install`.

You can install all modules or add individual modules, depending on your needs and integration type.
The `Adyen/WeChatPay` module needs to be explicitly added to support WeChat Pay.
The `Adyen/SwiftUI` module needs to be explicitly added to use the SwiftUI specific helpers.

```
pod 'Adyen'               // Add the Checkout subspec, the v6 entry point, with all modules except WeChat Pay and SwiftUI.
// Add individual modules
pod 'Adyen/Card'          // Card components.
pod 'Adyen/Session'       // Handler for the simplified checkout flow.
pod 'Adyen/Encryption'    // Encryption module.
pod 'Adyen/Components'    // All other payment components except WeChat Pay.
pod 'Adyen/Actions'       // Action Components.
pod 'Adyen/CardScanner'   // Card scanning support.
pod 'Adyen/WeChatPay'     // WeChat Pay Component.
pod 'Adyen/CashAppPay'    // Cash App Pay Component.
pod 'Adyen/SwiftUI'       // SwiftUI apps specific module.
```

:warning: _`Adyen/AdyenWeChatPay` and `AdyenWeChatPayInternal` modules doesn't support any simulators and can only be tested on a real device._

## Getting started

The v6 API is centered around `Checkout.setup(...)` as the entry point, `CheckoutConfiguration` as the shared configuration container, closure-based flow callbacks, and payment components created from the resulting checkout flow. See the [v6 foundations guide][docs.github.v6.readme] for the full reference.

> **Note:** Drop-in is not part of the v6 alpha yet. The v6 alpha exposes individual payment components; Drop-in support is planned for a later release.

### Session flow

Use the session flow when your backend starts checkout with [`/sessions`][apiExplorer.sessions]. Adyen manages the flow, including payment submission and action handling.

```swift
import Adyen
import AdyenActions
import AdyenCard
import AdyenCheckout

let configuration = try CheckoutConfiguration(
    environment: .test,
    amount: amount,
    clientKey: clientKey
) {
    CardConfiguration()
    AuthenticationConfiguration()
        .requestorAppURL(URL(string: "https://your-domain.example/adyen")!)
}

let checkout = try await Checkout.setup(
    with: sessionResponse,
    configuration: configuration,
    presentationDelegate: self
)
.onComplete { result in
    print(result.resultCode)
}
.onFailure { error in
    print(error.localizedDescription)
}

let component = try checkout.createPaymentComponent(for: .scheme)
```

In session flow the effective `amount` comes from the `/sessions` response, and settings such as `storePaymentMethodMode` and installments are session-controlled. See the [session flow guide][docs.github.v6.cardSession].

### Advanced flow

Use the advanced flow when your backend calls `/paymentMethods` and handles `/payments` and `/payments/details` itself.

```swift
let checkout = try await Checkout.setup(
    with: paymentMethods,
    configuration: configuration,
    presentationDelegate: self
)
.onSubmit { data in
    try await callPayments(with: data)
}
.onAdditionalDetails { data in
    try await callDetails(with: data)
}
.onComplete { result in
    print(result.resultCode)
}
.onFailure { error in
    print(error.localizedDescription)
}

let component = try checkout.createPaymentComponent(for: .scheme)
```

`callPayments(with:)` returns a `SubmitResult` and `callDetails(with:)` returns an `AdditionalDetailsResult`. See the [advanced flow guide][docs.github.v6.cardAdvanced].

### Action-only flow

If your app only needs to handle actions, set up checkout without a `SessionResponse` or `PaymentMethods`, and call `checkout.handle(action:)` when your backend returns an action.

```swift
let checkout = try await Checkout.setup(
    configuration: configuration,
    presentationDelegate: self
)
.onAdditionalDetails { data in
    try await callDetails(with: data)
}
.onComplete { result in
    print(result.resultCode)
}
.onFailure { error in
    print(error.localizedDescription)
}
```

### Presenting a payment component

`createPaymentComponent(for:)` returns a `CheckoutPaymentComponent`. Use its `viewController` for presentation.

```swift
guard let viewController = component.viewController else { return }

present(UINavigationController(rootViewController: viewController), animated: true)
```

Pass a `PresentationDelegate` to `Checkout.setup(...)` if checkout should present action components from your own UI layer.

```swift
extension CheckoutViewController: PresentationDelegate {
    func present(viewController: UIViewController) {
        present(viewController, animated: true)
    }
}
```

### Handling redirects

Pass incoming URLs to the SDK so active redirect actions can resume after the shopper returns from a browser or an external app. It is safe to pass all incoming URLs; any URL not belonging to an active checkout redirect is ignored.

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    Checkout.handleReturn(url: url)
    return true
}
```

For `SceneDelegate` and SwiftUI entry points, see the [v6 foundations guide][docs.github.v6.readme].

## Components

In v6 you present each payment method individually with `createPaymentComponent(for:)`, passing either a `PaymentMethodType` or the identifier of a stored payment method.

```swift
// A payment method from the current checkout flow.
let component = try checkout.createPaymentComponent(for: .scheme)

// A stored payment method.
guard let storedCard = checkout.paymentMethods?.stored
    .compactMap({ $0 as? StoredCardPaymentMethod })
    .first else { return }

let storedComponent = try checkout.createPaymentComponent(for: storedCard.identifier)
```

### Available Components

The v6 alpha currently supports:

* Card, including stored cards
* Apple Pay
* BLIK
* ACH Direct Debit
* Instant payment methods
* Stored payment methods

The remaining payment methods are still being migrated to the v6 API. For the components documented so far, see the [card component overview][docs.github.v6.card].

## Customization

Checkout-wide styling is configured with `CheckoutTheme` on `CheckoutConfiguration`, and applies to every payment component and action created from that checkout flow. Start from `CheckoutColors.default` and override only the tokens you need.

```swift
let theme = CheckoutTheme(
    colors: CheckoutColors(
        background: .systemBackground,
        container: .secondarySystemBackground,
        primary: .black,
        textOnPrimary: .white,
        highlight: .systemBlue,
        destructive: .systemRed,
        text: .label,
        textSecondary: .secondaryLabel
    )
)

let configuration = try CheckoutConfiguration(
    environment: .test,
    amount: amount,
    clientKey: clientKey
) {
    CardConfiguration()
}
.theme(theme)
```

A full list of color tokens can be found in the [checkout theme guide][docs.github.v6.theme].

Strings can be overridden at runtime with `localizationProvider(_:)` on `CheckoutConfiguration`, or by adding `.strings` and `.xcstrings` files to your app bundle to add a fully new language.

## See also

* [Complete Documentation](https://docs.adyen.com/online-payments/build-your-integration/?platform=iOS)

* [API Reference][reference]

* [v6 foundations][docs.github.v6.readme]

* [v5 to v6 migration notes][docs.github.v6.migration]

## Demo App

We provide a fully working **Demo App** to explore the checkout integration in a sandbox environment.

The Demo App includes:

* Sample integrations for Session Flow and Advanced Flow
* UIKit and SwiftUI examples
* Common payment methods (Card, Apple Pay, Instant Payments, Issuer List)

> **Note:** We recommend using your own backend server. Direct API usage with `ADYEN_SERVER_API_KEY` is possible for testing only and **not** for production.

For detailed setup, see the [Demo README](Demo/README.md).

## Support

If you have a feature request, or spotted a bug or a technical problem, create a GitHub issue. For other questions, contact our Support Team via [Customer Area](https://ca-live.adyen.com/ca/ca/contactUs/support.shtml) or via email: [support@adyen.com](mailto:support@adyen.com)

## Contributing
We strongly encourage you to join us in contributing to this repository so everyone can benefit from:
* New features and functionality
* Resolved bug fixes and issues
* Any general improvements


Read our [**contribution guidelines**](CONTRIBUTING.md) to find out how.

## License

This repository is open source and available under the MIT license. For more information, see the LICENSE file.

[reference]: https://adyen.github.io/adyen-ios/6.0.0-alpha.1/documentation/adyen/

[apiExplorer.sessions]: https://docs.adyen.com/api-explorer/#/CheckoutService/latest/post/sessions

[branch.v5]: https://github.com/Adyen/adyen-ios/tree/v5
[docs.github.v6.readme]: guides/v6/README.md
[docs.github.v6.card]: guides/v6/card.md
[docs.github.v6.cardSession]: guides/v6/card-session-flow.md
[docs.github.v6.cardAdvanced]: guides/v6/card-advanced-flow.md
[docs.github.v6.theme]: guides/v6/theme.md
[docs.github.v6.migration]: MIGRATION.md
