//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Reads external SDK configuration from a Base64-encoded JSON string passed via launch arguments
/// (`-config <base64>`) and merges it into `DemoAppSettings` so the existing
/// `ConfigurationConstants.current` picks up the values.
///
/// The JSON schema uses unified keys aligned with the native SDKs (e.g. `showCardholderName`).
/// All fields are optional — omitted fields preserve the existing value.
internal enum ExternalConfigurationReader {

    /// Reads and decodes the external configuration from launch arguments, if present.
    /// - Returns: The decoded `ExternalConfiguration`, or `nil` if no `-config` argument was passed
    ///   or the payload could not be decoded.
    static func readFromLaunchArguments() -> ExternalConfiguration? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let configIndex = arguments.firstIndex(of: "-config"),
              configIndex + 1 < arguments.count else {
            return nil
        }

        let base64 = arguments[configIndex + 1]
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }

        return try? JSONDecoder().decode(ExternalConfiguration.self, from: data)
    }
}

/// Parsed external configuration. All properties are optional so partial configs are supported.
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

    /// Returns a new `DemoAppSettings` with the external configuration applied.
    /// Only non-nil values from `external` override the existing values.
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
