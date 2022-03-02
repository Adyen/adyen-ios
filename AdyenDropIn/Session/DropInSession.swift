//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenActions
import Foundation

public final class DropInSession {
    internal weak var session: SessionProtocol?
    
    public init(session: SessionProtocol) {
        self.session = session
    }
    
    public func didFail(with error: Error, from dropInComponent: DropInComponent) {
        session?.didFail(with: error, from: dropInComponent)
    }
}
