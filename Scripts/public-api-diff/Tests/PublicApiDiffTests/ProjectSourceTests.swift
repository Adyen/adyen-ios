//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 24/06/2024.
//

@testable import public_api_diff
import XCTest

class ProjectSourceTests: XCTestCase {
    
    // MARK: - Remote
    
    func test_remote_validSource() throws {
        let repositoryUrl = "https://github.com/Adyen/adyen-ios.git"
        let separator = ProjectSource.gitSourceSeparator
        let branch = "develop"
        let rawProjectSourceValue = "\(branch)\(separator)\(repositoryUrl)"
        
        let mockFileHandler = MockFileHandler(handleFileExists: {
            XCTAssertEqual($0, rawProjectSourceValue)
            return false
        })
        
        let projectSource = try ProjectSource.from(
            "\(branch)\(separator)\(repositoryUrl)",
            fileHandler: mockFileHandler
        )
        
        XCTAssertEqual(
            projectSource,
            .remote(branch: branch, repository: repositoryUrl)
        )
    }
    
    func test_remote_invalidRepoUrl() throws {
        let repositoryUrl = ""
        let separator = ProjectSource.gitSourceSeparator
        let branch = "develop"
        let rawProjectSourceValue = "\(branch)\(separator)\(repositoryUrl)"
        
        let mockFileHandler = MockFileHandler(handleFileExists: {
            XCTAssertEqual($0, rawProjectSourceValue)
            return false
        })
        
        do {
            let source = try ProjectSource.from(
                rawProjectSourceValue,
                fileHandler: mockFileHandler
            )
            XCTAssertNil(source) // Guard to make sure that we catch if it succeeds
        } catch {
            let projectSourceError = try XCTUnwrap(error as? ProjectSourceError)
            
            XCTAssertEqual(
                projectSourceError,
                ProjectSourceError.invalidSourceValue(value: rawProjectSourceValue)
            )
        }
    }
    
    func test_remote_invalidSeparator() throws {
        let repositoryUrl = "https://github.com/Adyen/adyen-ios.git"
        let separator = "_"
        let branch = "develop"
        let rawProjectSourceValue = "\(branch)\(separator)\(repositoryUrl)"
        
        let mockFileHandler = MockFileHandler(handleFileExists: {
            XCTAssertEqual($0, rawProjectSourceValue)
            return false
        })
        
        do {
            let source = try ProjectSource.from(
                rawProjectSourceValue,
                fileHandler: mockFileHandler
            )
            XCTAssertNil(source) // Guard to make sure that we catch if it succeeds
        } catch {
            let projectSourceError = try XCTUnwrap(error as? ProjectSourceError)
            
            XCTAssertEqual(
                projectSourceError,
                ProjectSourceError.invalidSourceValue(value: rawProjectSourceValue)
            )
        }
    }
    
    // MARK: - Local
    
    func test_local_validSource() throws {
        let repositoryDirectoryPath = "/Some/Repository/Directory"
        let mockFileHandler = MockFileHandler(handleFileExists: {
            XCTAssertEqual($0, repositoryDirectoryPath)
            return true
        })
        
        let projectSource = try ProjectSource.from(
            repositoryDirectoryPath,
            fileHandler: mockFileHandler
        )
        
        XCTAssertEqual(
            projectSource,
            .local(path: repositoryDirectoryPath)
        )
    }
    
    func test_local_nonExistentDirectory() throws {
        let repositoryDirectoryPath = "/Some/Repository/Directory"
        let mockFileHandler = MockFileHandler(handleFileExists: {
            XCTAssertEqual($0, repositoryDirectoryPath)
            return false
        })
        
        let projectSource = try? ProjectSource.from(
            repositoryDirectoryPath,
            fileHandler: mockFileHandler
        )
        
        XCTAssertNil(projectSource)
    }
}
