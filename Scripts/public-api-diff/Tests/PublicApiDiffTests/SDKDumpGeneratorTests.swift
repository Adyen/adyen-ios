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
        
        let fileHandler = MockFileHandler(handleContents: { path in
            try? JSONEncoder().encode(expectedDump)
        })
        
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
        
        let fileHandler = MockFileHandler(handleContents: { path in
            nil
        })
        
        let xcodeTools = XcodeTools(shell: mockShell)
        
        let dumpGenerator = SDKDumpGenerator(
            projectDirectoryPath: projectDirectoryPath,
            fileHandler: fileHandler,
            xcodeTools: xcodeTools
        )
        
        let dump = dumpGenerator.generate(for: moduleName)
        
        XCTAssertNil(dump)
    }
}
