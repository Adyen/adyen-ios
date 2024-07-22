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
            XCTAssertEqual(command, "git clone -b \(branch) \(repository) \(targetDirectoryPath)")
            return ""
        }
        
        let mockFileHandler = MockFileHandler(handleFileExists: { _ in true })
        var mockLogger = MockLogger(logLevel: .default)
        mockLogger.handleLog = { message, subsystem in
            XCTAssertEqual(message, "🐱 Cloning repository @ branch into targetDirectoryPath")
            XCTAssertEqual(subsystem, "Git")
        }
        
        let git = Git(shell: mockShell, fileHandler: mockFileHandler, logger: mockLogger)
        try git.clone(repository, at: branch, targetDirectoryPath: targetDirectoryPath)
    }
    
    func test_clone_fail() throws {
        
        let repository = "repository"
        let branch = "branch"
        let targetDirectoryPath = "targetDirectoryPath"
        
        let mockShell = MockShell { command in
            XCTAssertEqual(command, "git clone -b \(branch) \(repository) \(targetDirectoryPath)")
            return ""
        }
        
        let mockFileHandler = MockFileHandler(handleFileExists: { _ in false })
        var mockLogger = MockLogger(logLevel: .default)
        mockLogger.handleLog = { message, subsystem in
            XCTAssertEqual(message, "🐱 Cloning repository @ branch into targetDirectoryPath")
            XCTAssertEqual(subsystem, "Git")
        }
        
        let git = Git(shell: mockShell, fileHandler: mockFileHandler, logger: mockLogger)
        
        do {
            try git.clone(repository, at: branch, targetDirectoryPath: targetDirectoryPath)
            XCTFail("Clone should have thrown an error")
        } catch {
            let fileHandlerError = try XCTUnwrap(error as? GitError)
            XCTAssertEqual(fileHandlerError, GitError.couldNotClone(branchOrTag: branch, repository: repository))
        }
    }
}
