//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 16/07/2024.
//

@testable import public_api_diff
import XCTest

class ProjectBuilderTests: XCTestCase {
    
    func test_buildPackage() throws {
        
        let baseWorkingDirectoryPath = "baseWorkingDirectoryPath"
        let localPath = "local/path"
        
        let removeItemExpectation = expectation(description: "FileHandler.removeItem is called once")
        
        var fileHandler = MockFileHandler()
        fileHandler.handleCreateDirectory = { path in
            let workingDirectoryPath = try XCTUnwrap(path.components(separatedBy: "/").first)
            XCTAssertEqual(workingDirectoryPath, baseWorkingDirectoryPath)
        }
        fileHandler.handleContentsOfDirectory = { path in
            XCTAssertEqual(path, localPath)
            return []
        }
        fileHandler.handleLoadData = { path in
            let components = path.split(separator: "/")
            XCTAssertEqual(components.first?.toString, baseWorkingDirectoryPath)
            XCTAssertEqual(components.last?.toString, "Package.swift")
            
            return try XCTUnwrap("PackageContent".data(using: .utf8))
        }
        fileHandler.handleRemoveItem = { path in
            let components = path.split(separator: "/")
            XCTAssertEqual(components.first?.toString, baseWorkingDirectoryPath)
            XCTAssertEqual(components.last?.toString, "Package.swift")
            
            removeItemExpectation.fulfill()
        }
        fileHandler.handleCreateFile = { path, data in
            XCTAssertEqual(String(data: data, encoding: .utf8), "PackageContent")
            
            let components = path.split(separator: "/")
            XCTAssertEqual(components.first?.toString, baseWorkingDirectoryPath)
            XCTAssertEqual(components.last?.toString, "Package.swift")
            return true
        }
        var shell = MockShell()
        shell.handleExecute = { command in
            //XCTAssertEqual(command, "")
            return ""
        }
        var logger = MockLogger()
        logger.handleLog = { message, subsystem in
            XCTAssertTrue(message.starts(with: "🛠️ Building project at `baseWorkingDirectoryPath"))
            XCTAssertEqual(subsystem, "ProjectBuilder")
        }
        
        let projectBuilder = ProjectBuilder(
            baseWorkingDirectoryPath: baseWorkingDirectoryPath,
            fileHandler: fileHandler,
            shell: shell,
            logger: logger
        )
        
        let projectWorkingDirectoryUrl = try projectBuilder.build(source: .local(path: "local/path"), scheme: nil)
        // TODO: Find a way to compare the url that has a random component
        // XCTAssertEqual(projectWorkingDirectoryUrl, URL(filePath: ""))
        
        wait(for: [removeItemExpectation], timeout: 1)
    }
}

private extension String.SubSequence {
    
    var toString: String {
        String(self)
    }
}
