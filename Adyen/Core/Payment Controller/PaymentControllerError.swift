//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension PaymentController {
    /// An error that occurred inside PaymentController.
    enum Error: Swift.Error {
        /// Indicates the payment was cancelled by the user.
        case cancelled
        
        /// Indicates the payment could not be completed because the user returned from a redirect through an invalid URL.
        case invalidReturnURL
        
    }
    
}
