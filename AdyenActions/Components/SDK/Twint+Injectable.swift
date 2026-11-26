//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
#if canImport(TwintSDK)
    @preconcurrency import TwintSDK
#endif

#if canImport(TwintSDK)
    extension Twint {

        @objc func fetchInstalledAppConfigurations(
            maxIssuerNumber: Int,
            completion: @escaping @MainActor ([TWAppConfiguration]) -> Void
        ) {
            Twint.fetchInstalledAppConfigurations(withMaxIssuerNumber: maxIssuerNumber) { configurations in
                let sendableConfigurations = Self.reCastedAppConfigurations(from: configurations)
                    .map(SendableAppConfiguration.init)
                Task { @MainActor in
                    completion(sendableConfigurations.map(\.appConfiguration))
                }
            }
        }
        
        @objc func pay(
            withCode code: String,
            appConfiguration: TWAppConfiguration,
            callback: String,
            completionHandler: @escaping @MainActor @Sendable (Error?) -> Void
        ) {
            Twint.pay(
                withCode: code,
                appConfiguration: appConfiguration,
                callback: callback,
                completionHandler: { error in Task { @MainActor in completionHandler(error) } }
            )
        }

        @objc
        func registerForUOF(
            withCode code: String,
            appConfiguration: TWAppConfiguration,
            callback: String,
            completionHandler: @escaping @MainActor @Sendable (Error?) -> Void
        ) {
            Twint.registerForUOF(
                withCode: code,
                appConfiguration: appConfiguration,
                callback: callback,
                completionHandler: { error in Task { @MainActor in completionHandler(error) } }
            )
        }

        @objc func controller(
            for installedAppConfigurations: [TWAppConfiguration],
            selectionHandler: @escaping @MainActor (TWAppConfiguration?) -> Void,
            cancelHandler: @escaping @MainActor () -> Void
        ) -> UIAlertController? {
            Twint.controller(
                for: installedAppConfigurations,
                selectedConfigurationHandler: { selection in
                    let sendableSelection = selection.map(SendableAppConfiguration.init)
                    Task { @MainActor in selectionHandler(sendableSelection?.appConfiguration) }
                },
                cancelHandler: { Task { @MainActor in cancelHandler() } }
            )
        }
        
        @discardableResult @objc func handleOpen(
            _ url: URL,
            responseHandler: @escaping @MainActor @Sendable (Error?) -> Void
        ) -> Bool {
            Twint.handleOpen(url) { error in Task { @MainActor in responseHandler(error) } }
        }
        
        /// A `Sendable` snapshot of a `TWAppConfiguration` that can safely cross isolation boundaries.
        private struct SendableAppConfiguration {

            let appURLScheme: String
            let appDisplayName: String?

            init(_ configuration: TWAppConfiguration) {
                appURLScheme = configuration.appURLScheme
                appDisplayName = configuration.appDisplayName
            }

            var appConfiguration: TWAppConfiguration {
                let configuration = TWAppConfiguration(appURLScheme: appURLScheme)
                configuration.appDisplayName = appDisplayName
                return configuration
            }
        }

        /// Re-casting **`[TWAppConfiguration]`** into **`[TWAppConfiguration]`** via **`[NSObject]`**
        ///
        /// - **Background:** If different SDKs that use the **TwintSDK** internally are imported by an app,
        /// it can lead to the system providing a **TwintSDK** class of the other SDK, resulting in a runtime crash when type checking.
        /// See: [Github Issue](https://github.com/Adyen/adyen-ios/issues/1902)
        /// - **Solution:** To work around this we implicitly cast the `[TWAppConfiguration]` to an `[NSObject]`
        /// and then explicitly back to `[TWAppConfiguration]` which makes sure the correctly loaded class is used.
        private static func reCastedAppConfigurations(from configurations: [NSObject]?) -> [TWAppConfiguration] {
            configurations?.compactMap { $0 as? TWAppConfiguration } ?? []
        }
    }
#endif
