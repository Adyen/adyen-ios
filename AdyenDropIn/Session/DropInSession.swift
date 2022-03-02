//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// DropIn session adapter.
public final class DropInSession {
    internal let session: SessionProtocol
    
    /// Initializes an instance of `DropInSession`
    ///
    /// - Parameter session: The session object
    public init(session: SessionProtocol) {
        self.session = session
    }
}
