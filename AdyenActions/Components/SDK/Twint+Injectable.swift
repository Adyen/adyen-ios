//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
#if canImport(TwintSDK)
    import TwintSDK
#endif

#if canImport(TwintSDK)
    extension Twint {
        @objc func fetchInstalledAppConfigurations(completion: @escaping ([TWAppConfiguration]) -> Void) {
            Twint.fetchInstalledAppConfigurations(withMaxIssuerNumber: .max) { configurations in
                completion(configurations ?? [])
            }
        }
        
        @objc func pay(withCode code: String, appConfiguration: TWAppConfiguration, callback: String) -> Error? {
            Twint.pay(withCode: code, appConfiguration: appConfiguration, callback: callback)
        }

        @objc
        func registerForUOF(withCode code: String, appConfiguration: TWAppConfiguration, callback: String) -> Error? {
            Twint.registerForUOF(withCode: code, appConfiguration: appConfiguration, callback: callback)
        }

        @objc func controller(
            for installedAppConfigurations: [TWAppConfiguration],
            selectionHandler: @escaping (TWAppConfiguration?) -> Void,
            cancelHandler: @escaping () -> Void
        ) -> UIAlertController? {
            Twint.controller(
                for: installedAppConfigurations.map { $0 },
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
    }
#endif
