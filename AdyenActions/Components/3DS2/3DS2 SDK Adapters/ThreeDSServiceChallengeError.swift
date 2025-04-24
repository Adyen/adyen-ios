//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Errors that could happen during a challenge
internal enum ThreeDSServiceChallengeError: Error, Equatable {
    /// The transaction was not initialized during fingerprinting.
    case transactionNotInitialized
    /// Edge case which should never occur.
    case errorAndResultAreNil(errorPayload: String)
    /// The challenge has been cancelled.
    case cancelled(errorPayload: String)
    /// The sdk faced an error performing the challenge.
    case challengeError(errorPayload: String)
}
