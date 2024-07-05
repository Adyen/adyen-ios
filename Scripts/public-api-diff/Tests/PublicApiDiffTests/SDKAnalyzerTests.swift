//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class SDKAnalyzerTests: XCTestCase {
    
    func test_analyze_noChanges() throws {
        let mockShell = MockShell { command in "" }
        
        var mockFileHandler = MockFileHandler()
        mockFileHandler.handleLoadData = { path in
            let packageName = path.components(separatedBy: "/").first
            let resourcePath = try XCTUnwrap(Bundle.module.path(forResource: packageName, ofType: "txt"))
            return try XCTUnwrap(FileManager.default.contents(atPath: resourcePath))
        }
        mockFileHandler.handleFileExists = { _ in
            return true
        }
        
        let xcodeTools = XcodeTools(shell: mockShell)
        
        let analyzer = SDKAnalyzer(
            fileHandler: mockFileHandler,
            xcodeTools: xcodeTools
        )
        
        let expectedChanges: [String: [SDKAnalyzer.Change]] = [:]
        
        let changes = try analyzer.analyze(
            old: "NewPackage",
            new: "NewPackage"
        )
        
        XCTAssertEqual(changes, expectedChanges)
    }
    
    func test_analyze_targetChanges() throws {
        
        let mockShell = MockShell { command in
            print(command)
            return ""
        }
        
        var mockFileHandler = MockFileHandler()
        mockFileHandler.handleLoadData = { path in
            let packageName = path.components(separatedBy: "/").first
            let resourcePath = try XCTUnwrap(Bundle.module.path(forResource: packageName, ofType: "txt"))
            return try XCTUnwrap(FileManager.default.contents(atPath: resourcePath))
        }
        mockFileHandler.handleFileExists = { _ in
            return true
        }
        
        let xcodeTools = XcodeTools(shell: mockShell)
        
        let analyzer = SDKAnalyzer(
            fileHandler: mockFileHandler,
            xcodeTools: xcodeTools
        )
        
        let expectedChanges: [String: [SDKAnalyzer.Change]] = [
            "Package.swift": [
                .init(changeType: .removal, parentName: "", changeDescription: "`.library(name: \"OldLibrary\", ...)` was removed"),
                .init(changeType: .addition, parentName: "", changeDescription: "`.library(name: \"NewLibrary\", ...)` was added")
            ]
        ]
        
        let changes = try analyzer.analyze(
            old: "OldPackage",
            new: "NewPackage"
        )
        
        XCTAssertEqual(changes, expectedChanges)
    }
    
    func test_analyze_codeChanges() throws {
        
        // TODO: Implement
        
        let mockShell = MockShell { command in
            print(command)
            return ""
        }
        
        var mockFileHandler = MockFileHandler()
        mockFileHandler.handleLoadData = { path in
            let packageName = path.components(separatedBy: "/").first
            let resourcePath = try XCTUnwrap(Bundle.module.path(forResource: packageName, ofType: "txt"))
            return try XCTUnwrap(FileManager.default.contents(atPath: resourcePath))
        }
        mockFileHandler.handleFileExists = { _ in
            return true
        }
        
        let xcodeTools = XcodeTools(shell: mockShell)
        
        let analyzer = SDKAnalyzer(
            fileHandler: mockFileHandler,
            xcodeTools: xcodeTools
        )
        
        let expectedChanges: [String: [SDKAnalyzer.Change]] = [:]
        
        let changes = try analyzer.analyze(
            old: "NewPackage",
            new: "NewPackage"
        )
        
        XCTAssertEqual(changes, expectedChanges)
    }
}
