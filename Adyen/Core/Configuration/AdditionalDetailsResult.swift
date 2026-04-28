//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Result returned by the merchant's `onAdditionalDetails` callback in the advanced flow.
public enum AdditionalDetailsResult: Sendable {

    /// The `/payments/details` call completed and carries a final `resultCode`.
    ///
    /// `resultCode` is always a `String`. When the underlying SDK delegate path does not carry a
    /// resultCode (e.g. `Checkout.didComplete(from:)` in the advanced, non-session flow), the SDK
    /// emits an empty string to keep the type uniform with `SubmitResult.completion` and with the
    /// Adyen Checkout SDK callback surface.
    case completion(resultCode: String)
}
