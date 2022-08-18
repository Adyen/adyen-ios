//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user is redirected to a URL.
public struct RedirectAction: Decodable {
    
    /// The URL to which to redirect the user.
    public let url: URL
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String?
    
    /// Native redirect data.
    public let nativeRedirectData: String?
    
    /// Initializes a redirect action.
    ///
    /// - Parameters:
    ///   - url: The URL to which to redirect the user.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    ///   - nativeRedirectData: Native redirect data.
    public init(url: URL, paymentData: String?, nativeRedirectData: String? = nil) {
        self.url = url
        self.paymentData = paymentData
        self.nativeRedirectData = nativeRedirectData
    }
}
