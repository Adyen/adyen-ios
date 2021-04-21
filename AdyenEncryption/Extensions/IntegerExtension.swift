//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension NSInteger {

    internal func encodedOctets() -> [CUnsignedChar] {
        // Short form
        guard self >= 128 else { return [CUnsignedChar(self)] }

        // Long form
        let index = Int(log2(Double(self)) / 8 + 1)
        var len = self
        var result = [CUnsignedChar(index + 0x80)]

        for _ in 0..<index {
            result.insert(CUnsignedChar(len & 0xFF), at: 1)
            len = len >> 8
        }

        return result
    }

}
