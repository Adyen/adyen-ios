//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 15/07/2024.
//

@testable import public_api_diff
import XCTest

class SDKDumpGeneratorTests: XCTestCase {
    
    func test_loadFromJson_dummy() throws {
        let abiJsonPath = try XCTUnwrap(Bundle.module.path(forResource: "dummy.abi", ofType: "json"))
        let abiFlatDefinitionPath = try XCTUnwrap(Bundle.module.path(forResource: "dummi-abi-flat-definition", ofType: "txt"))
        try compare(abiJsonFilePath: abiJsonPath, toFlatDefinition: abiFlatDefinitionPath)
    }
    
    private func compare(abiJsonFilePath: String, toFlatDefinition flatDefinitionFilePath: String) throws {
        
        let abiJsonUrl = try XCTUnwrap(URL(filePath: abiJsonFilePath))
        
        var fileHandler = MockFileHandler()
        fileHandler.handleLoadData = { path in
            XCTAssertEqual(path, abiJsonFilePath)
            return try FileManager.default.loadData(from: path)
        }
        
        let generator = SDKDumpGenerator(fileHandler: fileHandler)
        let sdkDump = try generator.generate(for: abiJsonUrl)
        
        let expectedFlatDefinition = try FileManager.default.loadString(from: flatDefinitionFilePath)
        var expectedLines = expectedFlatDefinition.components(separatedBy: "\n")
        if let lastLine = expectedLines.last, lastLine.isEmpty {
            // Unfortunately Xcode always adds an empty line at the end when copying over
            expectedLines.removeLast()
        }
        
        let lines = sdkDump.flatDescription.components(separatedBy: "\n")
        XCTAssertEqual(expectedLines.count, lines.count)
        
        // Comparing line by line to make debugging easier
        for lineIndex in (0..<lines.count) {
            if lines[lineIndex] != expectedLines[lineIndex] {
                XCTFail("Line \(lineIndex + 1): `\(lines[lineIndex])` is not equal to `\(expectedLines[lineIndex])`")
                break
            }
        }
        
        // To update the dummi-abi-flat-definition.txt file
        // just print the flatDescription and copy the content over into the file
        // print(sdkDump.flatDescription)
    }
}

// MARK: - Convenience

extension SDKDump {
    
    var flatDescription: String {
        var components = [String]()
        components += root.flatChildDescriptions()
        return components.joined(separator: "\n")
    }
}

extension SDKDump.Element {
    
    func flatChildDescriptions() -> [String] {
        var definitions = [String]()
        children.forEach { child in
            if child.declKind == nil { return }
            definitions += [child.description] + child.flatChildDescriptions()
        }
        return definitions
    }
}
