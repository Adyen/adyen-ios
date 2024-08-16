//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

struct MockOutputGenerator: OutputGenerating {
    
    var onGenerate: ([String: [Change]], [String], ProjectSource, ProjectSource) throws -> String
    
    func generate(from changesPerTarget: [String: [Change]], allTargets: [String], oldSource: ProjectSource, newSource: ProjectSource) throws -> String {
        try onGenerate(changesPerTarget, allTargets, oldSource, newSource)
    }
}
