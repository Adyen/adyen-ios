//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

internal struct CardAnalyticsConfiguration: Encodable {
    
    private enum Constants {
        static let stringSeparator = ","
    }
    
    private let billingAddressMode: String?
    private let billingAddressAllowedCountries: String?
    private let billingAddressRequired: String
    private let showsHolderNameField: String
    private let showsStorePaymentMethodField: String
    private let showsSecurityCodeField: String
    private let showKCPType: String
    private let socialSecurityNumberMode: String
    private let enableStoredDetails: String
    private let hasInstallmentOptions: String
    private let allowedCardTypes: String?
    
    internal init(configuration: CardComponent.Configuration) {
        self.billingAddressMode = configuration.billingAddress.mode.analyticsDescription
        self.billingAddressAllowedCountries = configuration.billingAddress.countryCodes?.joined(separator: Constants.stringSeparator)
        if case .required = configuration.billingAddress.requirementPolicy {
            self.billingAddressRequired = String(true)
        } else {
            self.billingAddressRequired = String(false)
        }
        self.showsHolderNameField = String(configuration.showsHolderNameField)
        self.showsStorePaymentMethodField = String(configuration.showsStorePaymentMethodField)
        self.showsSecurityCodeField = String(configuration.showsSecurityCodeField)
        self.enableStoredDetails = String(configuration.showsStorePaymentMethodField)
        self.hasInstallmentOptions = String(configuration.installmentConfiguration != nil)
        self.showKCPType = configuration.koreanAuthenticationMode.analyticsDescription
        self.socialSecurityNumberMode = configuration.socialSecurityNumberMode.analyticsDescription
        self.allowedCardTypes = configuration.allowedCardTypes?
            .map(\.rawValue)
            .joined(separator: Constants.stringSeparator)
    }
}

private extension CardComponent.AddressFormType {
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

private extension CardComponent.FieldVisibility {
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
