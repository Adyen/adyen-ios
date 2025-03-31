//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import class Adyen3DS2.ADYAppearanceConfiguration
import Foundation

internal struct FingerprintServiceParameters {
    internal let directoryServerIdentifier: String
    internal let directoryServerPublicKey: String
    internal let directoryServerRootCertificates: String
    internal let deviceExcludedParameters: [String: Any]?
    internal let appearanceConfiguration: Adyen3DS2.ADYAppearanceConfiguration
    internal let threeDSMessageVersion: String
}
