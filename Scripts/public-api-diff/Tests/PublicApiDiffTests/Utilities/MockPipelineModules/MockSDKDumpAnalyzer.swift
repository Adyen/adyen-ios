//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

struct MockSDKDumpAnalyzer: SDKDumpAnalyzing {
    
    var onAnalyze: (SDKDump, SDKDump) throws -> [Change]
    
    func analyze(old: SDKDump, new: SDKDump) throws -> [Change] {
        try onAnalyze(old, new)
    }
}
