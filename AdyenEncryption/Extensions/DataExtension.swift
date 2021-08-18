//
// Copyright (c) 2021 Adyen N.V.
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
    
    internal init?(base64URLEncoded base64URLString: String) {
        self.init(base64Encoded: base64URLString.base64String())
    }
    
    internal func base64URLString() -> String {
        var result = base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
}
