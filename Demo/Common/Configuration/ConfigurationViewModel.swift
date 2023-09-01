//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenCard
import SwiftUI

@available(iOS 13.0.0, *)

final class ConfigurationViewModel: ObservableObject {
    
    @Published var countryCode: String = ""
    @Published var currencyCode: String = ""
    @Published var value: String = ""
    @Published var apiVersion: String = ""
    @Published var merchantAccount: String = ""
    @Published var showsHolderNameField = false
    @Published var showsStorePaymentMethodField = true
    @Published var showsStoredCardSecurityCodeField = true
    @Published var showsSecurityCodeField = true
    @Published var addressMode: CardComponentConfiguration.AddressFormType = .none
    @Published var socialSecurityNumberMode: CardComponent.FieldVisibility = .auto
    @Published var koreanAuthenticationMode: CardComponent.FieldVisibility = .auto
    @Published var allowDisablingStoredPaymentMethods: Bool = false
    @Published var allowsSkippingPaymentList: Bool = false
    @Published var allowPreselectedPaymentView: Bool = true
    @Published var applePayMerchantIdentifier: String = ""
    @Published var allowOnboarding: Bool = false
    @Published var analyticsIsEnabled: Bool = true

    private let onDone: (DemoAppSettings) -> Void
    private let configuration: DemoAppSettings
    
    init(
        configuration: DemoAppSettings,
        onDone: @escaping (DemoAppSettings) -> Void
    ) {
        self.onDone = onDone
        self.configuration = configuration
        
        applyConfiguration(configuration)
    }
    
    private func applyConfiguration(_ configuration: DemoAppSettings) {
        self.countryCode = configuration.countryCode
        self.currencyCode = configuration.currencyCode
        self.value = configuration.value.description
        self.apiVersion = configuration.apiVersion.description
        self.merchantAccount = configuration.merchantAccount
        self.showsHolderNameField = configuration.cardComponentConfiguration.showsHolderNameField
        self.showsStorePaymentMethodField = configuration.cardComponentConfiguration.showsStorePaymentMethodField
        self.showsStoredCardSecurityCodeField = configuration.cardComponentConfiguration.showsStoredCardSecurityCodeField
        self.showsSecurityCodeField = configuration.cardComponentConfiguration.showsSecurityCodeField
        self.addressMode = configuration.cardComponentConfiguration.addressMode
        self.socialSecurityNumberMode = configuration.cardComponentConfiguration.socialSecurityNumberMode
        self.koreanAuthenticationMode = configuration.cardComponentConfiguration.koreanAuthenticationMode
        self.allowDisablingStoredPaymentMethods = configuration.dropInConfiguration.allowDisablingStoredPaymentMethods
        self.allowsSkippingPaymentList = configuration.dropInConfiguration.allowsSkippingPaymentList
        self.allowPreselectedPaymentView = configuration.dropInConfiguration.allowPreselectedPaymentView
        self.applePayMerchantIdentifier = configuration.applePayConfiguration.merchantIdentifier
        self.allowOnboarding = configuration.applePayConfiguration.allowOnboarding
        self.analyticsIsEnabled = configuration.analyticsSettings.isEnabled
    }
    
    func doneTapped() {
        onDone(currentConfiguration)
    }
    
    func defaultTapped() {
        applyConfiguration(DemoAppSettings.defaultConfiguration)
    }
    
    private var currentConfiguration: DemoAppSettings {
        DemoAppSettings(
            countryCode: countryCode,
            value: Int(value) ?? configuration.value,
            currencyCode: currencyCode,
            apiVersion: Int(apiVersion) ?? configuration.apiVersion,
            merchantAccount: merchantAccount, cardComponentConfiguration: CardComponentConfiguration(
                showsHolderNameField: showsHolderNameField,
                showsStorePaymentMethodField: showsStorePaymentMethodField,
                showsStoredCardSecurityCodeField: showsStoredCardSecurityCodeField,
                showsSecurityCodeField: showsSecurityCodeField,
                addressMode: addressMode,
                socialSecurityNumberMode: socialSecurityNumberMode,
                koreanAuthenticationMode: koreanAuthenticationMode
            ),
            dropInConfiguration: DropInConfiguration(allowDisablingStoredPaymentMethods: allowDisablingStoredPaymentMethods,
                                                     allowsSkippingPaymentList: allowsSkippingPaymentList,
                                                     allowPreselectedPaymentView: allowPreselectedPaymentView),
            applePayConfiguration: ApplePayConfiguration(merchantIdentifier: applePayMerchantIdentifier,
                                                         allowOnboarding: allowOnboarding),
            analyticsConfiguration: AnalyticConfiguration(isEnabled: analyticsIsEnabled)
        )
    }

    static let currencies: [CurrencyDisplayInfo] = {
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
    
    static let countries: [CountryDisplayInfo] = {
        let countryCodeKey = NSLocale.Key.countryCode.rawValue
        return NSLocale.isoCountryCodes.compactMap { code -> CountryDisplayInfo? in
            let identifier = NSLocale.localeIdentifier(fromComponents: [countryCodeKey: code])
            return (NSLocale.current as NSLocale).displayName(forKey: .identifier, value: identifier)
                .map { CountryDisplayInfo(code: code, name: $0) }
        }
    }()
}

struct CountryDisplayInfo: Hashable {
    let code: String
    let name: String
}

struct CurrencyDisplayInfo: Hashable, Comparable {
    let code: String
    let symbol: String
    
    static func < (lhs: CurrencyDisplayInfo, rhs: CurrencyDisplayInfo) -> Bool {
        lhs.code < rhs.code
    }
}
