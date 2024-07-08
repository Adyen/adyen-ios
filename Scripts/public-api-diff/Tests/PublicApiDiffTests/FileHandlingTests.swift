//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class FileHandlingTests: XCTestCase {
    
    func test_write() throws {
        
        let output = "output"
        let filePath = "output/file/path.txt"
        
        var fileHandler = MockFileHandler()
        fileHandler.handleRemoveItem = { path in
            XCTAssertEqual(path, filePath)
        }
        
        // Success scenario
        
        fileHandler.handleCreateFile = { path, data in
            XCTAssertEqual(path, filePath)
            XCTAssertEqual(String(data: data, encoding: .utf8), output)
            return true
        }
        
        try fileHandler.write(output, to: filePath)
        
        // Fail scenario
        
        fileHandler.handleCreateFile = { _, _ in
            false
        }
        
        do {
            try fileHandler.write(output, to: filePath)
            XCTFail("Write should have thrown an error")
        } catch {
            let fileHandlerError = try XCTUnwrap(error as? FileHandlerError)
            XCTAssertEqual(fileHandlerError, FileHandlerError.couldNotCreateFile(outputFilePath: filePath))
        }
    }
    
    func test_createCleanRepository() throws {
        
        let filePath = "directory/path"
        
        var fileHandler = MockFileHandler()
        fileHandler.handleRemoveItem = { path in
            XCTAssertEqual(path, filePath)
        }
        fileHandler.handleCreateDirectory = { path in
            XCTAssertEqual(path, filePath)
        }
        
        try fileHandler.createCleanDirectory(atPath: filePath)
    }
    
    func test_load() throws {
        
        let filePath = "input/file/path.txt"
        let expectedContent = "content"
        
        var fileHandler = MockFileHandler()
        
        // Success scenario
        
        fileHandler.handleLoadData = { path in
            XCTAssertEqual(path, filePath)
            return try XCTUnwrap(expectedContent.data(using: .utf8))
        }
        
        let content = try fileHandler.loadString(from: filePath)
        XCTAssertEqual(expectedContent, content)
        
        // Fail scenario
        
        fileHandler.handleLoadData = { path in
            throw FileHandlerError.couldNotLoadFile(filePath: path)
        }
        
        do {
            _ = try fileHandler.loadString(from: filePath)
            XCTFail("Load should have thrown an error")
        } catch {
            let fileHandlerError = try XCTUnwrap(error as? FileHandlerError)
            XCTAssertEqual(fileHandlerError, FileHandlerError.couldNotLoadFile(filePath: filePath))
        }
    }
}
