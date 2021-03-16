//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol Payload: Encodable {
    func jsonData() throws -> Data
}

extension Payload {
    internal func jsonData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
