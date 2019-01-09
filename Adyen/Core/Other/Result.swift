//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An enum used for operations which result in either success or failure. A successful result contains a single parameter of type `T`.
public enum Result<T> {
    /// Indicates a successful result.
    case success(T)
    
    /// Indicates a failure.
    case failure(Error)
    
}
