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
    public extension Twint {
        
        
        /// Fetches the installed apps based on the configuration
        /// - Parameters:
        ///   - useExplicitIssuers: If `true` - all supported issuers have to be added to the `LSApplicationQueriesSchemes` and only the installed apps are returned. If `false` all issuers up to issuer number 39 are returned regardless of whether installed or not.
        ///   - completion: Returns the matching configurations.
        ///
        ///   To support issuers from 40 and above "twint-extended" has to be added to the `LSApplicationQueriesSchemes`.
        @objc func fetchInstalledAppConfigurations(
            useExplicitIssuers: Bool,
            completion: @escaping ([TWAppConfiguration]) -> Void
        ) {
            
            // Documented scenarios:
            // - useExplicitIssuers: Bool (true -> set withMaxIssuerNumber = 0 / false -> set withMaxIssuerNumber = .max)
            // - "twint-extended" (Provided / Not provided)
            
            
            
            
            
            // Twint.fetchInstalledAppConfigurations(withMaxIssuerNumber:)
            //
            // - Provide a maxIssuerNumber <= 39 (e.g. 0)
            //   - IGNORES `LSApplicationQueriesSchemes` EXCEPT FOR "twint-extended"
            //   - A clamped range between the maxIssuerNumber and 39, regardless of whether installed or not
            //   - With "twint-extended" (and app installed) + all fetched configs above 39 (e.g. 40-46)
            //
            // - Provide any maxIssuerNumber over 39 (e.g. .max, but any number above 39 has the same effect)
            //   - NEEDS INSTALLED APPS TO SHOW UP IN `LSApplicationQueriesSchemes` TO GET RECOGNIZED
            //   - As many issuers as there are installed (But clamped between 1-39) - only the ones in the `LSApplicationQueriesSchemes` appear
            //   - With "twint-extended" (and app installed) + all fetched configs above 39 (e.g. 40-46)
            //
            // If "twint-extended" is provided and an app is installed that can has an url scheme "twint-extended" it adds all fetched configs above 39 (e.g. 40-46)
            
            Twint.fetchInstalledAppConfigurations(withMaxIssuerNumber: .max) { configurations in
                print((configurations ?? []).count)
                completion(configurations ?? [])
                // Any maxIssuerNumber above 39 has the same effect
                
                // As many issuers as there are installed (But clamped between 1-39)
                // With "twint-extended" (and app installed) + all fetched configs above 39 (e.g. 40-46)
                
                Twint.fetchInstalledAppConfigurations(withMaxIssuerNumber: 0) { configurations in
                    print((configurations ?? []).count)
                    completion(configurations ?? [])
                    // 38 issuers (1-39), regardless of whether installed or not
                    // With "twint-extended" (and app installed) + all fetched configs above 39 (e.g. 40-46)
                    
                    Twint.fetchInstalledAppConfigurations(withMaxIssuerNumber: 3) { configurations in
                        print((configurations ?? []).count)
                        completion(configurations ?? [])
                        // 9 issuers (30-39), regardless of whether installed or not + All installed ones (But clamped between 1-39)
                        // With "twint-extended" (and app installed) + all fetched configs above 39 (e.g. 40-46)
                    }
                }
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
