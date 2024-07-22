//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

@testable import public_api_diff
import XCTest

class ABIGeneratorTests: XCTestCase {
    
    func test_noSchemeProvided_shouldHandleAsPackage() throws {
        
        var shell = MockShell()
        shell.handleExecute = { _ in
            let packageDescription = SwiftPackageDescription(
                defaultLocalization: "en-en",
                products: [],
                targets: [],
                toolsVersion: "1.0"
            )
            let encodedPackageDescription = try! JSONEncoder().encode(packageDescription)
            return String(data: encodedPackageDescription, encoding: .utf8)!
        }
        
        var fileHandler = MockFileHandler()
        fileHandler.handleFileExists = { _ in
            return true
        }
        fileHandler.handleLoadData = { _ in
            try XCTUnwrap("".data(using: .utf8))
        }
        
        var logger = MockLogger()
        logger.handleLog = { message, subsystem in
            XCTAssertEqual(message, "📋 Generating ABI files for `description`")
            XCTAssertEqual(subsystem, "PackageABIGenerator")
        }
        
        let abiGenerator = ABIGenerator(
            shell: shell,
            fileHandler: fileHandler,
            logger: logger
        )
        
        let output = try abiGenerator.generate(for: URL(filePath: "projectDir"), scheme: nil, description: "description")
        let expectedOutput = [ABIGeneratorOutput]()
        XCTAssertEqual(output, expectedOutput)
    }
    
    func test_schemeProvided_shouldHandleAsProject() throws {
        
        let scheme = "Scheme"
        let pathToSwiftModule = "path/to/\(scheme).swiftmodule"
        let expectedAbiJsonUrl = URL(filePath: "\(pathToSwiftModule)/abi.json")
        
        var shell = MockShell()
        shell.handleExecute = { _ in
            return "\(pathToSwiftModule)\nsomeMoreStuff.txt"
        }
        
        var fileHandler = MockFileHandler()
        fileHandler.handleContentsOfDirectory = { _ in
            ["abi.json"]
        }
        
        var logger = MockLogger()
        logger.handleLog = { message, subsystem in
            XCTAssertEqual(message, "📋 Locating ABI file for `description`")
            XCTAssertEqual(subsystem, "ProjectABIProvider")
        }
        logger.handleDebug = { message, subsystem in
            XCTAssertEqual(message, "- `abi.json`")
            XCTAssertEqual(subsystem, "ProjectABIProvider")
        }
        
        let abiGenerator = ABIGenerator(
            shell: shell,
            fileHandler: fileHandler,
            logger: logger
        )
        
        let output = try abiGenerator.generate(for: URL(filePath: "projectDir"), scheme: scheme, description: "description")
        let expectedOutput: [ABIGeneratorOutput] = [.init(
            targetName: scheme,
            abiJsonFileUrl: expectedAbiJsonUrl
        )]
        
        XCTAssertEqual(output, expectedOutput)
    }
}
