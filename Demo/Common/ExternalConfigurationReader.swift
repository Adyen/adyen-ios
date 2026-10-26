//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal enum ExternalConfigurationReader {

    static func readFromLaunchArguments() -> ExternalConfiguration? {
        read(from: ProcessInfo.processInfo.arguments)
    }

    static func read(from arguments: [String]) -> ExternalConfiguration? {
        guard let configIndex = arguments.firstIndex(of: "-config"),
              configIndex + 1 < arguments.count else {
            return nil
        }

        let base64 = arguments[configIndex + 1]
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            print("Error: Failed to parse base64 configuration string.")
            return nil
        }

        do {
            return try JSONDecoder().decode(ExternalConfiguration.self, from: data)
        } catch {
            print("Error: Failed to decode ExternalConfiguration: \(error)")
            return nil
        }
    }
}

internal struct ExternalConfiguration: Codable {
    internal let card: ExternalCardConfiguration?
    internal let dropIn: ExternalDropInConfiguration?
    internal let applePay: ExternalApplePayConfiguration?

    internal init(
        card: ExternalCardConfiguration? = nil,
        dropIn: ExternalDropInConfiguration? = nil,
        applePay: ExternalApplePayConfiguration? = nil
    ) {
        self.card = card
        self.dropIn = dropIn
        self.applePay = applePay
    }

    private enum CodingKeys: String, CodingKey {
        case card = "CARD_CONFIGURATION"
        case dropIn = "DROP_IN_CONFIGURATION"
        case applePay = "APPLE_PAY_CONFIGURATION"
    }
}

internal struct ExternalCardConfiguration: Codable {
    internal let showCardholderName: Bool?

    internal init(showCardholderName: Bool? = nil) {
        self.showCardholderName = showCardholderName
    }
}

internal struct ExternalDropInConfiguration: Codable {
    internal let hideStoredPaymentMethods: Bool?
    internal let startWithLastStoredPaymentMethod: Bool?

    internal init(hideStoredPaymentMethods: Bool? = nil, startWithLastStoredPaymentMethod: Bool? = nil) {
        self.hideStoredPaymentMethods = hideStoredPaymentMethods
        self.startWithLastStoredPaymentMethod = startWithLastStoredPaymentMethod
    }
}

internal struct ExternalApplePayConfiguration: Codable {
    internal let plainPaymentSheet: Bool?

    internal init(plainPaymentSheet: Bool? = nil) {
        self.plainPaymentSheet = plainPaymentSheet
    }
}

internal extension DemoAppSettings {

    func applying(_ external: ExternalConfiguration) -> DemoAppSettings {
        var cardSettings = cardSettings
        if let showCardholderName = external.card?.showCardholderName {
            cardSettings.showCardholderName = showCardholderName
        }

        var dropInSettings = dropInSettings
        if let hideStoredPaymentMethods = external.dropIn?.hideStoredPaymentMethods {
            dropInSettings.hideStoredPaymentMethods = hideStoredPaymentMethods
        }
        if let startWithLastStoredPaymentMethod = external.dropIn?.startWithLastStoredPaymentMethod {
            dropInSettings.startWithLastStoredPaymentMethod = startWithLastStoredPaymentMethod
        }

        return DemoAppSettings(
            countryCode: countryCode,
            value: value,
            currencyCode: currencyCode,
            merchantAccount: merchantAccount,
            cardSettings: cardSettings,
            dropInSettings: dropInSettings,
            threeDSConfigurationSettings: threeDSConfigurationSettings,
            applePaySettings: applePaySettings,
            analyticsSettings: analyticsSettings,
            themeSettings: themeSettings
        )
    }
}
