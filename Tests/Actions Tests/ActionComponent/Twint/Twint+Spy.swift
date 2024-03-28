//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@testable @_spi(AdyenInternal) import Adyen
@testable import AdyenActions

#if canImport(TwintSDK)

import TwintSDK

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
    
    internal typealias HandleOpenBlock = (
        _ url: URL,
        _ responseHandler: @escaping ((any Error)?) -> Void
    ) -> Bool
    
    internal var handleFetchInstalledAppConfigurations: HandleFetchBlock
    internal var handlePay: HandlePayBlock
    internal var handleController: HandleControllerBlock
    internal var handleOpenUrl: HandleOpenBlock
    
    internal init(
        handleFetchInstalledAppConfigurations: @escaping HandleFetchBlock,
        handlePay: @escaping HandlePayBlock,
        handleController: @escaping HandleControllerBlock,
        handleOpenUrl: @escaping HandleOpenBlock
    ) {
        self.handleFetchInstalledAppConfigurations = handleFetchInstalledAppConfigurations
        self.handlePay = handlePay
        self.handleController = handleController
        self.handleOpenUrl = handleOpenUrl
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
    
    @objc override func handleOpen(_ url: URL, responseHandler: @escaping ((any Error)?) -> Void) -> Bool {
        handleOpenUrl(url, responseHandler)
    }
}

#endif
