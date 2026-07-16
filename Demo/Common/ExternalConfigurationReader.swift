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
            return nil
        }

        return try? JSONDecoder().decode(ExternalConfiguration.self, from: data)
    }
}

internal struct ExternalConfiguration: Decodable {
    internal let card: ExternalCardConfiguration?

    private enum CodingKeys: String, CodingKey {
        case card = "CARD_CONFIGURATION"
    }
}

internal struct ExternalCardConfiguration: Decodable {
    internal let showCardholderName: Bool?
}

internal extension DemoAppSettings {

    func applying(_ external: ExternalConfiguration) -> DemoAppSettings {
        var cardSettings = cardSettings
        if let showCardholderName = external.card?.showCardholderName {
            cardSettings.showCardholderName = showCardholderName
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
