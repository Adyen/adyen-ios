//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 15/07/2024.
//

@testable import public_api_diff
import XCTest

class SDKDumpGeneratorTests: XCTestCase {
    
    func test_loadFromJson() throws {
        
        let abiJsonPath = try XCTUnwrap(Bundle.module.path(forResource: "dummy.abi", ofType: "json"))
        let abiJsonUrl = try XCTUnwrap(URL(filePath: abiJsonPath))
        
        var fileHandler = MockFileHandler()
        fileHandler.handleLoadData = { path in
            XCTAssertEqual(path, abiJsonPath)
            return try FileManager.default.loadData(from: path)
        }
        
        let generator = SDKDumpGenerator(fileHandler: fileHandler)
        _ = try generator.generate(for: abiJsonUrl)
        
        // TODO: Check if it was decoded correctly
    }
}
