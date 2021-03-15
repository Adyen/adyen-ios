//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct BinPayload: Payload {

    private var bin: String?

    internal func add(bin: String) -> Payload {
        var payloadCopy = self
        payloadCopy.bin = bin
        return payloadCopy
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bin, forKey: .value)

        let timestampString = ISO8601DateFormatter().string(from: Date())
        try container.encode(timestampString, forKey: .timestamp)
    }

    private enum CodingKeys: String, CodingKey {
        case value = "binValue"
        case timestamp = "generationtime"
    }
}
