//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation

/// The Session object.
public final class Session: SessionProtocol {
    
    private let sessionData: String
    
    private init(sessionData: String) {
        self.sessionData = sessionData
    }
    
    /// The designated initializer to asynchronously initializes a new instance of `Session`.
    ///
    /// - Parameters:
    ///   - sessionData: The session data
    ///   - completion: The completion closure.
    public static func initialize(withSessionData sessionData: String, completion: (Session) -> Void) {
        // TODO: Implement the setup call
        completion(Session(sessionData: sessionData))
    }
    
    public func didFail(with error: Error, from dropInComponent: Component) {
        // TODO: Callback merchant
    }
}
