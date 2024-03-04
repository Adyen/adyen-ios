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
            Twint.fetchInstalledAppConfigurations { configurations in
                completion(configurations ?? [])
            }
        }
        
        @objc func pay(withCode code: String, appConfiguration: TWAppConfiguration, callback: String) -> Error? {
            Twint.pay(withCode: code, appConfiguration: appConfiguration, callback: callback)
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
    }
#endif

internal class TwintSpy: Twint {
    
    internal typealias HandleFetchBlock = (@escaping ([TWAppConfiguration]) -> Void) -> Void
    
    internal typealias HandlePayBlock = (
        _ code: String,
        _ appConfiguration: TWAppConfiguration,
        _ callbackAppScheme: String
    ) -> Error?
    
    internal typealias HandleControllerBlock = (
        _ installedAppConfigurations: [TWAppConfiguration],
        _ selectionHandler: @escaping (TWAppConfiguration?) -> Void,
        _ cancelHandler: @escaping () -> Void
    ) -> UIAlertController?
    
    internal var handleFetchInstalledAppConfigurations: HandleFetchBlock
    internal var handlePay: HandlePayBlock
    internal var handleController: HandleControllerBlock
    
    internal init(
        handleFetchInstalledAppConfigurations: @escaping HandleFetchBlock,
        handlePay: @escaping HandlePayBlock,
        handleController: @escaping HandleControllerBlock
    ) {
        self.handleFetchInstalledAppConfigurations = handleFetchInstalledAppConfigurations
        self.handlePay = handlePay
        self.handleController = handleController
    }
    
    @objc override internal func fetchInstalledAppConfigurations(
        completion: @escaping ([TWAppConfiguration]) -> Void
    ) {
        handleFetchInstalledAppConfigurations(completion)
    }
    
    @objc override internal func pay(
        withCode code: String,
        appConfiguration: TWAppConfiguration,
        callback callbackAppScheme: String
    ) -> Error? {
        handlePay(code, appConfiguration, callbackAppScheme)
    }
    
    @objc override internal func controller(
        for installedAppConfigurations: [TWAppConfiguration],
        selectionHandler: @escaping (TWAppConfiguration?) -> Void,
        cancelHandler: @escaping () -> Void
    ) -> UIAlertController? {
        handleController(installedAppConfigurations, selectionHandler, cancelHandler)
    }
    
}
