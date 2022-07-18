# Installation

Adyen Components for iOS are available through either CocoaPods, Carthage or Swift Package Manager.

### Requirements

- iOS 11.0+
- Xcode 11.0+
- Swift 5.1

### CocoaPods

1. Add `pod 'Adyen'` to your `Podfile`.
2. Run `pod install`.

You can install all modules or add individual modules, depending on your needs and integration type.
The `Adyen/WeChatPay` module needs to be explicitly added to support WeChat Pay.
The `Adyen/SwiftUI` module needs to be explicitly added to use the SwiftUI specific helpers.

```
pod 'Adyen'               // Add DropIn with all modules except Session, WeChat Pay and SwiftUI.
// Add individual modules
pod 'Adyen/Session'       // For the new Sessions integration.
pod 'Adyen/Card'          // Card components.
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
* `AdyenSession`: For the new, simplified checkout flow.
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

* `AdyenDropIn`: all modules except `AdyenWeChatPay`, `AdyenSwiftUI` and `AdyenSession`.
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
