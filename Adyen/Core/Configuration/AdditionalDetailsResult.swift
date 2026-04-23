//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Result returned by the merchant's `onAdditionalDetails` callback in the advanced flow.
///
/// Mirrors the generic advanced-flow branch view for the details stage: `Finished | Error`.
public enum AdditionalDetailsResult: Sendable {
    
    /// The `/payments/details` call finished and carries a final `resultCode`.
    ///
    /// `resultCode` is always a `String`. When the underlying SDK delegate path does not carry a
    /// resultCode (e.g. `Checkout.didComplete(from:)` in the advanced, non-session flow), the SDK
    /// emits an empty string to keep the type uniform with `SubmitResult.finished` and with the
    /// Android callback surface.
    case finished(resultCode: String)
    
    /// An error occurred while handling the additional-details callback.
    case error(Error)
}
