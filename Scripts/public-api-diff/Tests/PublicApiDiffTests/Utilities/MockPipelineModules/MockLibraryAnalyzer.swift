//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

struct MockLibraryAnalyzer: LibraryAnalyzing {
    
    var onAnalyze: (URL, URL) throws -> [Change]
    
    func analyze(oldProjectUrl: URL, newProjectUrl: URL) throws -> [Change] {
        try onAnalyze(oldProjectUrl, newProjectUrl)
    }
}
