//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

@testable import public_api_diff
import XCTest

class ABIGeneratorTests: XCTestCase {
    
    func test_emptyPackage() throws {
        
        let shell = MockShell { command in
            return command
        }
        let xcodeTools = XcodeTools(shell: shell)
        
        var fileHandler = MockFileHandler()
        fileHandler.handleFileExists = { _ in
            return true
        }
        fileHandler.handleLoadData = { _ in
            "".data(using: .utf8)!
        }
        
        let abiGenerator = ABIGenerator(xcodeTools: xcodeTools, fileHandler: fileHandler)
        
        let output = try abiGenerator.generate(for: URL(filePath: ""))
        let expectedOutput = [ABIGeneratorOutput]()
        XCTAssertEqual(output, expectedOutput)
    }
}
