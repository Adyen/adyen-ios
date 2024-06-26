//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 26/06/2024.
//

import Foundation

extension SDKDump.Element {
    
    // Protocol conformance node
    struct Conformance: Codable, Equatable {
        var printedName: String
        
        enum CodingKeys: String, CodingKey {
            case printedName
        }
    }
}
