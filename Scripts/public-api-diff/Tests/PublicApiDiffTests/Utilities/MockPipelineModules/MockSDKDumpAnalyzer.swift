//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

@testable import public_api_diff
import XCTest

struct MockSDKDumpAnalyzer: SDKDumpAnalyzing {
    
    var onAnalyze: (SDKDump, SDKDump) throws -> [Change]
    
    func analyze(old: SDKDump, new: SDKDump) throws -> [Change] {
        try onAnalyze(old, new)
    }
}
