//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Result returned by `onAdditionalDetails` callback in the advanced flow.
public enum AdditionalDetailsResult: Sendable {

    /// The `/payments/details` call completed with a final `resultCode`.
    case completion(resultCode: String)
}
