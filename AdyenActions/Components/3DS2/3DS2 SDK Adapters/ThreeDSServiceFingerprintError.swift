//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Errors that could happen during fingerprinting
internal enum ThreeDSServiceFingerprintError: Error {
    /// The sdk faced an error performing fingerprinting.
    case fingerprintingError(errorPayload: String)
}
