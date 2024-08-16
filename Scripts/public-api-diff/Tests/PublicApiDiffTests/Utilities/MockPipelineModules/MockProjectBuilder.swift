//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

struct MockProjectBuilder: ProjectBuilding {
    
    var onBuild: (ProjectSource, String?) throws -> URL
    
    func build(source: ProjectSource, scheme: String?) throws -> URL {
        try onBuild(source, scheme)
    }
}
