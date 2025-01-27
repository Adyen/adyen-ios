//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
#if canImport(TwintSDK)
    import TwintSDK
#endif

#if canImport(TwintSDK)
    extension Twint {
        
        @objc func fetchInstalledAppConfigurations(
            maxIssuerNumber: Int,
            completion: @escaping ([TWAppConfiguration]) -> Void
        ) {
            Twint.fetchInstalledAppConfigurations(withMaxIssuerNumber: maxIssuerNumber) { configurations in
                completion(Self.reCastedAppConfigurations(from: configurations))
            }
        }
        
        @objc func pay(
            withCode code: String,
            appConfiguration: TWAppConfiguration,
            callback: String,
            completionHandler: @escaping (Error?) -> Void
        ) {
            Twint.pay(
                withCode: code,
                appConfiguration: appConfiguration,
                callback: callback,
                completionHandler: completionHandler
            )
        }

        @objc
        func registerForUOF(
            withCode code: String,
            appConfiguration: TWAppConfiguration,
            callback: String,
            completionHandler: @escaping (Error?) -> Void
        ) {
            Twint.registerForUOF(
                withCode: code,
                appConfiguration: appConfiguration,
                callback: callback,
                completionHandler: completionHandler
            )
        }

        @objc func controller(
            for installedAppConfigurations: [TWAppConfiguration],
            selectionHandler: @escaping (TWAppConfiguration?) -> Void,
            cancelHandler: @escaping () -> Void
        ) -> UIAlertController? {
            Twint.controller(
                for: installedAppConfigurations,
                selectedConfigurationHandler: { selectionHandler($0) },
                cancelHandler: { cancelHandler() }
            )
        }
        
        @discardableResult @objc func handleOpen(
            _ url: URL,
            responseHandler: @escaping (Error?) -> Void
        ) -> Bool {
            Twint.handleOpen(url, withResponseHandler: responseHandler)
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
