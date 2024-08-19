//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

struct MockSDKDumpGenerator: SDKDumpGenerating {
    
    var onGenerate: (URL) throws -> SDKDump
    
    func generate(for abiJsonFileUrl: URL) throws -> SDKDump {
        try onGenerate(abiJsonFileUrl)
    }
}
