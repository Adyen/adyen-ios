//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// Validates a client key https://docs.adyen.com/user-management/client-side-authentication
public final class ClientKeyValidator: RegularExpressionValidator {

    /// :nodoc:
    public init() {
        let regex = #"^[a-z]{4,8}_[a-zA-Z0-9]{8,128}$"#
        super.init(regularExpression: regex, minimumLength: 13, maximumLength: 140)
    }

}
