//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An error that occurred during the validation or use of a client key.
public enum ClientKeyError: Error, LocalizedError {

    /// An error that occurred during the validation
    case invalidClientKey

    public var errorDescription: String? {
        """
        The entered client key is invalid.
        Valid client key starts with environment name (e.x. `live_XXXXXXXXXX`).
        """
    }

}

/// Validates a client key https://docs.adyen.com/user-management/client-side-authentication
public final class ClientKeyValidator: RegularExpressionValidator {

    public init() {
        let regex = #"^[a-z]{4,8}_[a-zA-Z0-9]{8,128}$"#
        super.init(regularExpression: regex, minimumLength: 13, maximumLength: 140)
    }

}
