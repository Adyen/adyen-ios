//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SDKDump.Element {
    
    // Protocol conformance node
    struct Conformance: Codable, Equatable, Hashable {
        
        var printedName: String
        
        enum CodingKeys: String, CodingKey {
            case printedName
        }
    }
}

extension SDKDump.Element.Conformance: Comparable {
    
    static func < (lhs: SDKDump.Element.Conformance, rhs: SDKDump.Element.Conformance) -> Bool {
        lhs.printedName < rhs.printedName
    }
}
