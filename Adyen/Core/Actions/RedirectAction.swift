//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user is redirected to a URL.
public struct RedirectAction: Decodable {
    
    /// The URL to which to redirect the user.
    public let url: URL
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String
}
