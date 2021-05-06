//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

@available(iOS 13.0.0, *)
internal final class ConfigurationViewModel: ObservableObject {
    
    @Published internal var countryCode: String = ""
    @Published internal var currencyCode: String = ""
    @Published internal var value: String = ""
    @Published internal var apiVersion: String = ""
    @Published internal var merchantAccount: String = ""
    
    private let onDone: (Configuration) -> Void
    private let configuration: Configuration
    
    internal init(
        configuration: Configuration,
        onDone: @escaping (Configuration) -> Void
    ) {
        self.onDone = onDone
        self.configuration = configuration
        
        applyConfiguration(configuration)
    }
    
    private func applyConfiguration(_ configuration: Configuration) {
        self.countryCode = configuration.countryCode
        self.currencyCode = configuration.currencyCode
        self.value = configuration.value.description
        self.apiVersion = configuration.apiVersion.description
        self.merchantAccount = configuration.merchantAccount
    }
    
    internal func doneTapped() {
        onDone(currentConfiguration)
    }
    
    internal func defaultTapped() {
        applyConfiguration(Configuration.defaultConfiguration)
    }
    
    private var currentConfiguration: Configuration {
        Configuration(
            countryCode: countryCode,
            value: Int(value) ?? configuration.value,
            currencyCode: currencyCode,
            apiVersion: Int(apiVersion) ?? configuration.apiVersion,
            merchantAccount: merchantAccount
        )
    }
    
    internal static let currencies: [CurrencyDisplayInfo] = {
        let currencyCodeKey = NSLocale.Key.currencyCode.rawValue
        let uniqueCurrencies = Set(
            NSLocale.isoCurrencyCodes
                .compactMap { code -> CurrencyDisplayInfo? in
                    let locale = NSLocale(localeIdentifier: NSLocale.localeIdentifier(fromComponents: [currencyCodeKey: code]))
                    return locale.currencyCode
                        .map { CurrencyDisplayInfo(code: $0, symbol: locale.currencySymbol) }
                }
        )
        
        return Array(uniqueCurrencies).sorted()
    }()
    
    internal static let countries: [CountryDisplayInfo] = {
        let countryCodeKey = NSLocale.Key.countryCode.rawValue
        return NSLocale.isoCountryCodes.compactMap { code -> CountryDisplayInfo? in
            let identifier = NSLocale.localeIdentifier(fromComponents: [countryCodeKey: code])
            return (NSLocale.current as NSLocale).displayName(forKey: .identifier, value: identifier)
                .map { CountryDisplayInfo(code: code, name: $0) }
        }
    }()
}

internal struct CountryDisplayInfo: Hashable {
    internal let code: String
    internal let name: String
}

internal struct CurrencyDisplayInfo: Hashable, Comparable {
    internal let code: String
    internal let symbol: String
    
    internal static func < (lhs: CurrencyDisplayInfo, rhs: CurrencyDisplayInfo) -> Bool {
        lhs.code < rhs.code
    }
}
