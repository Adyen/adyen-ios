//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenCard
import SwiftUI

@available(iOS 13.0.0, *)

internal final class ConfigurationViewModel: ObservableObject {
    
    @Published internal var countryCode: String = ""
    @Published internal var currencyCode: String = ""
    @Published internal var value: String = ""
    @Published internal var apiVersion: String = ""
    @Published internal var merchantAccount: String = ""
    @Published internal var showsHolderNameField = false
    @Published internal var showsStorePaymentMethodField = true
    @Published internal var showsStoredCardSecurityCodeField = true
    @Published internal var showsSecurityCodeField = true
    @Published internal var addressMode: CardSettings.AddressFormType = .none
    @Published internal var socialSecurityNumberMode: CardComponent.FieldVisibility = .auto
    @Published internal var koreanAuthenticationMode: CardComponent.FieldVisibility = .auto
    @Published internal var allowDisablingStoredPaymentMethods: Bool = false
    @Published internal var allowsSkippingPaymentList: Bool = false
    @Published internal var allowPreselectedPaymentView: Bool = true
    @Published internal var applePayMerchantIdentifier: String = ""
    @Published internal var allowOnboarding: Bool = false
    @Published internal var analyticsIsEnabled: Bool = true
    @Published internal var installmentsEnabled: Bool = false
    @Published internal var showInstallmentAmount: Bool = false

    private let onDone: (DemoAppSettings) -> Void
    private let configuration: DemoAppSettings
    
    internal init(
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
        self.showsHolderNameField = configuration.cardSettings.showsHolderNameField
        self.showsStorePaymentMethodField = configuration.cardSettings.showsStorePaymentMethodField
        self.showsStoredCardSecurityCodeField = configuration.cardSettings.showsStoredCardSecurityCodeField
        self.showsSecurityCodeField = configuration.cardSettings.showsSecurityCodeField
        self.addressMode = configuration.cardSettings.addressMode
        self.socialSecurityNumberMode = configuration.cardSettings.socialSecurityNumberMode
        self.koreanAuthenticationMode = configuration.cardSettings.koreanAuthenticationMode
        self.allowDisablingStoredPaymentMethods = configuration.dropInSettings.allowDisablingStoredPaymentMethods
        self.allowsSkippingPaymentList = configuration.dropInSettings.allowsSkippingPaymentList
        self.allowPreselectedPaymentView = configuration.dropInSettings.allowPreselectedPaymentView
        self.applePayMerchantIdentifier = configuration.applePaySettings.merchantIdentifier
        self.allowOnboarding = configuration.applePaySettings.allowOnboarding
        self.analyticsIsEnabled = configuration.analyticsSettings.isEnabled
        self.installmentsEnabled = configuration.cardSettings.enableInstallments
        self.showInstallmentAmount = configuration.cardSettings.showsInstallmentAmount
    }
    
    internal func doneTapped() {
        onDone(currentConfiguration)
    }
    
    internal func defaultTapped() {
        applyConfiguration(DemoAppSettings.defaultConfiguration)
    }
    
    private var currentConfiguration: DemoAppSettings {
        DemoAppSettings(
            countryCode: countryCode,
            value: Int(value) ?? configuration.value,
            currencyCode: currencyCode,
            apiVersion: Int(apiVersion) ?? configuration.apiVersion,
            merchantAccount: merchantAccount,
            cardSettings: CardSettings(
                showsHolderNameField: showsHolderNameField,
                showsStorePaymentMethodField: showsStorePaymentMethodField,
                showsStoredCardSecurityCodeField: showsStoredCardSecurityCodeField,
                showsSecurityCodeField: showsSecurityCodeField,
                addressMode: addressMode,
                socialSecurityNumberMode: socialSecurityNumberMode,
                koreanAuthenticationMode: koreanAuthenticationMode,
                enableInstallments: installmentsEnabled,
                showsInstallmentAmount: showInstallmentAmount
            ),
            dropInSettings: DropInSettings(allowDisablingStoredPaymentMethods: allowDisablingStoredPaymentMethods,
                                           allowsSkippingPaymentList: allowsSkippingPaymentList,
                                           allowPreselectedPaymentView: allowPreselectedPaymentView),
            applePaySettings: ApplePaySettings(merchantIdentifier: applePayMerchantIdentifier,
                                               allowOnboarding: allowOnboarding),
            analyticsSettings: AnalyticsSettings(isEnabled: analyticsIsEnabled)
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
