//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class GitTests: XCTestCase {
    
    func test_clone_success() throws {
        
        let repository = "repository"
        let branch = "branch"
        let targetDirectoryPath = "targetDirectoryPath"
        
        let mockShell = MockShell { command in
            print(command)
            XCTAssertEqual(command, "git clone -b \(branch) \(repository) \(targetDirectoryPath)")
            return ""
        }
        
        let mockFileHandler = MockFileHandler(handleFileExists: { _ in true })
        
        let git = Git(shell: mockShell, fileHandler: mockFileHandler)
        try git.clone(repository, at: branch, targetDirectoryPath: targetDirectoryPath)
    }
    
    func test_clone_fail() throws {
        
        let repository = "repository"
        let branch = "branch"
        let targetDirectoryPath = "targetDirectoryPath"
        
        let mockShell = MockShell { command in
            print(command)
            XCTAssertEqual(command, "git clone -b \(branch) \(repository) \(targetDirectoryPath)")
            return ""
        }
        
        let mockFileHandler = MockFileHandler(handleFileExists: { _ in false })
        
        let git = Git(shell: mockShell, fileHandler: mockFileHandler)
        
        do {
            try git.clone(repository, at: branch, targetDirectoryPath: targetDirectoryPath)
            XCTFail("Clone should have thrown an error")
        } catch {
            let fileHandlerError = try XCTUnwrap(error as? FileHandlerError)
            XCTAssertEqual(fileHandlerError, FileHandlerError.pathDoesNotExist(path: targetDirectoryPath))
        }
    }
}
