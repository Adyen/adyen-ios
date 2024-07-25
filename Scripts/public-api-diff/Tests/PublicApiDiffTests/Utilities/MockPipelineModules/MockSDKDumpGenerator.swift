//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

@testable import public_api_diff
import XCTest

struct MockSDKDumpGenerator: SDKDumpGenerating {
    
    var onGenerate: (URL) throws -> SDKDump
    
    func generate(for abiJsonFileUrl: URL) throws -> SDKDump {
        try onGenerate(abiJsonFileUrl)
    }
}
