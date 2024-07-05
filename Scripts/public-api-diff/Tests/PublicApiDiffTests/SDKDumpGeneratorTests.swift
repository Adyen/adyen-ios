//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class SDKDumpGeneratorTests: XCTestCase {
    
    func test_dump_validModuleName() throws {
        let moduleName = UUID().uuidString
        let projectDirectoryPath = UUID().uuidString
        
        let expectedDump = SDKDump(root: .init(kind: "kind", name: "name", printedName: "printedName"))
        
        let mockShell = MockShell { command in "" }
        
        var fileHandler = MockFileHandler()
        
        fileHandler.handleLoadData = { _ in
            try JSONEncoder().encode(expectedDump)
        }
        
        fileHandler.handleFileExists = { _ in
            true
        }
        
        let xcodeTools = XcodeTools(shell: mockShell)
        
        let dumpGenerator = SDKDumpGenerator(
            projectDirectoryPath: projectDirectoryPath,
            fileHandler: fileHandler,
            xcodeTools: xcodeTools
        )
        
        let dump = try XCTUnwrap(dumpGenerator.generate(for: moduleName))
        
        XCTAssertEqual(dump, expectedDump)
    }
    
    func test_dump_invalidModuleName() throws {
        let moduleName = "I_DO_NOT_EXIST"
        let projectDirectoryPath = UUID().uuidString
        
        let mockShell = MockShell { command in "" }
        
        var fileHandler = MockFileHandler()
        
        fileHandler.handleLoadData = { path in
            throw FileHandlerError.couldNotLoadFile(filePath: path)
        }
        
        fileHandler.handleFileExists = { _ in
            false
        }
        
        let xcodeTools = XcodeTools(shell: mockShell)
        
        let dumpGenerator = SDKDumpGenerator(
            projectDirectoryPath: projectDirectoryPath,
            fileHandler: fileHandler,
            xcodeTools: xcodeTools
        )
        
        do {
            _ = try dumpGenerator.generate(for: moduleName)
            XCTFail("Generate should have thrown an error")
        } catch {
            let fileHandlerError = try XCTUnwrap(error as? FileHandlerError)
            XCTAssertEqual(fileHandlerError, FileHandlerError.pathDoesNotExist(path: projectDirectoryPath.appending("/api_dump.json")))
        }
    }
}
