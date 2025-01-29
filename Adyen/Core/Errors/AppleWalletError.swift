//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An error that occurred during adding a pass to apple wallet.
public enum AppleWalletError: LocalizedError {

    /// Indicates adding the pass to apple wallet failed.
    case failedToAddToAppleWallet
}
