//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

extension UnknownError {
    internal static let transactionNotInitialized = UnknownError(errorDescription: "Transaction not initialized")
    internal static let serviceIsNil = UnknownError(errorDescription: "ADYService is nil.")
    internal static let resultAndErrorAreNil = UnknownError(errorDescription: "Both error and result are nil, this should never happen.")
}
