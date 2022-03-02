//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// The data supplied by an action component upon completion.
public struct ActionComponentData {
    
    /// The additional details supplied by the action component.
    public let details: AdditionalDetails
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String?
    
    /// Initializes the action component data.
    ///
    /// :nodoc:
    ///
    /// - Parameters:
    ///   - details: The additional details supplied by the action component.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public init(details: AdditionalDetails, paymentData: String?) {
        self.details = details
        self.paymentData = paymentData
    }
}
