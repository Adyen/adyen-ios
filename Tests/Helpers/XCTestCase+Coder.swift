//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import AdyenComponents
import XCTest

internal extension Coder {

    static func decode<T: Decodable>(_ dictionary: [String: Any]) throws -> T {
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])

        return try decode(data)
    }

}
