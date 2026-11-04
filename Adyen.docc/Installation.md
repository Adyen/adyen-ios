# Installation

Adyen Components for iOS are available through Swift Package Manager.

### Minimum Requirements

- iOS 16.0
- Xcode 16.0
- Swift 5.7

@TabNavigator {
    @Tab(SPM) {
        1. Follow Apple's [Adding Package Dependencies to Your App](
        https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app
        ) guide on how to add a Swift Package dependency.
        2. Use `https://github.com/Adyen/adyen-ios` as the repository URL.
        3. Specify the version to be at least `4.9.0`.

        You can add all modules or select individual modules to add to your integration.
        The `AdyenWeChatPay` module needs to be explicitly added to support WeChat Pay.
        The `AdyenSwiftUI` module needs to be explicitly added to use the SwiftUI specific helpers.

        * `AdyenDropIn`: all modules except `AdyenWeChatPay` `AdyenCashAppPay`, `AdyenSwiftUI` and `AdyenSession`.
        * `AdyenSession`: handler for the simplified checkout flow.
        * `AdyenCard`: the card components.
        * `AdyenComponents`: all other payment components except WeChat Pay.
        * `AdyenActions`:  action components.
        * `AdyenEncryption`: encryption.
        * `AdyenWeChatPay`: WeChat Pay component.
        * `AdyenCashAppPay`: Cash App Pay component.
        * `AdyenSwiftUI`: SwiftUI apps specific module.
        
        > important: Swift Package Manager for Xcode 12.0 and 12.1 have a [know issue](https://bugs.swift.org/browse/SR-13343) when importing dependencies that depend on binary dependencies. A workaround is described [here](https://forums.swift.org/t/swiftpm-binarytarget-dependency-and-code-signing/38953).
    }
    
    @Tab(CocoaPods) {
        > important: CocoaPods is no longer supported. `5.27.0` is the last v5 version and `6.0.0-alpha.1` the last v6 version available on CocoaPods. Use Swift Package Manager to get newer versions.
    }
}

> note: `AdyenWeChatPay` and `AdyenWeChatPayInternal` modules don't support any simulators and can only be tested on a real device.
