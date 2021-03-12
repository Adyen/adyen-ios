//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public protocol Payload: Encodable {
    func jsonData() -> Data?
}

extension Payload {
    internal func jsonData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
