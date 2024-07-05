//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class GitTests: XCTestCase {
    func test_clone() throws {
        
        let repository = "repository"
        let branch = "branch"
        let targetDirectoryPath = "targetDirectoryPath"
        
        let mockShell = MockShell { command in
            print(command)
            XCTAssertEqual(command, "git clone -b \(branch) \(repository) \(targetDirectoryPath)")
            return ""
        }
        
        let git = Git(shell: mockShell)
        git.clone(repository, at: branch, targetDirectoryPath: targetDirectoryPath)
    }
}
