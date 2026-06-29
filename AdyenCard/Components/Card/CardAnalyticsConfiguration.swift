//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal struct CardAnalyticsConfiguration: AnalyticsStringDictionaryConvertible {
    
    private enum Constants {
        static let stringSeparator = ","
    }
    
    private let billingAddressMode: String?
    private let billingAddressAllowedCountries: String?
    private let billingAddressHideForCardBrands: String?
    private let showCardholderName: Bool
    private let hideCVC: Bool
    private let showKCPType: String
    private let socialSecurityNumberVisibility: String
    private let enableStoredDetails: Bool
    private let hasInstallmentOptions: Bool
    private let brands: String?
    
    internal init(configuration: CardConfiguration) {
        self.billingAddressMode = configuration.billingAddressMode.analyticsDescription
        self.billingAddressAllowedCountries = configuration.billingAddressMode.supportedCountryCodes?
            .joined(separator: Constants.stringSeparator)
        let hideForCardBrands = configuration.billingAddressMode.hideForCardBrands
        self.billingAddressHideForCardBrands = hideForCardBrands.isEmpty
            ? nil
            : hideForCardBrands
            .map(\.rawValue)
            .sorted()
            .joined(separator: Constants.stringSeparator)
        self.showCardholderName = configuration.showCardholderName
        self.hideCVC = !configuration.showSecurityCode
        self.enableStoredDetails = configuration.showStorePaymentMethod
        self.hasInstallmentOptions = configuration.installmentConfiguration != nil
        self.showKCPType = configuration.koreanAuthenticationVisibility.analyticsDescription
        self.socialSecurityNumberVisibility = configuration.socialSecurityNumberVisibility.analyticsDescription
        self.brands = configuration.supportedCardBrands?
            .map(\.rawValue)
            .joined(separator: Constants.stringSeparator)
    }
}

private extension BillingAddressMode {
    var analyticsDescription: String? {
        switch self {
        case .lookup:
            return "lookup"
        case .full:
            return "full"
        case .postalCode:
            return "partial"
        case .none:
            return nil
        }
    }
}

private extension CardConfiguration.FieldVisibility {
    var analyticsDescription: String {
        switch self {
        case .show:
            return "show"
        case .hide:
            return "hide"
        case .auto:
            return "auto"
        }
    }
}
