//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension Data {

    internal var asBytes: [CUnsignedChar] {
        let start = (self as NSData).bytes.bindMemory(to: CUnsignedChar.self, capacity: self.count)
        let count = self.count / MemoryLayout<CUnsignedChar>.size
        return [CUnsignedChar](UnsafeBufferPointer<CUnsignedChar>(start: start, count: count))
    }

}
