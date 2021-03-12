//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class BinPayloadBuilder {

    internal var payload = BinPaylod()

    internal func add(bin: String) {
        payload.value = bin
    }

    internal struct BinPaylod: Payload {

        internal var value: String?

        internal func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .value)

            let timestampString = ISO8601DateFormatter().string(from: Date())
            try container.encode(timestampString, forKey: .timestamp)
        }

        private enum CodingKeys: String, CodingKey {
            case value = "binValue"
            case timestamp = "generationtime"
        }
    }
}
