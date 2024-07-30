//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

struct MockABIGenerator: ABIGenerating {
    
    var onGenerate: (URL, String?, String) throws -> [ABIGeneratorOutput]
    
    func generate(for projectDirectory: URL, scheme: String?, description: String) throws -> [ABIGeneratorOutput] {
        try onGenerate(projectDirectory, scheme, description)
    }
}
