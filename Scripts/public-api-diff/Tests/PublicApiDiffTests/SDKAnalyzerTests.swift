//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 24/06/2024.
//

@testable import public_api_diff
import XCTest

class SDKAnalyzerTests: XCTestCase {
    
    func test_analyze_noChanges() throws {
        let mockShell = MockShell { command in return "" }
        
        var mockFileHandler = MockFileHandler()
        mockFileHandler.handleContents = { path in
            let packageName = path.components(separatedBy: "/").first
            guard let resourcePath = Bundle.module.path(forResource: packageName, ofType: "txt") else { return nil }
            return FileManager.default.contents(atPath: resourcePath)
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
        mockFileHandler.handleContents = { path in
            let packageName = path.components(separatedBy: "/").first
            guard let resourcePath = Bundle.module.path(forResource: packageName, ofType: "txt") else { return nil }
            return FileManager.default.contents(atPath: resourcePath)
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
        mockFileHandler.handleContents = { path in
            let packageName = path.components(separatedBy: "/").first
            guard let resourcePath = Bundle.module.path(forResource: packageName, ofType: "txt") else { return nil }
            return FileManager.default.contents(atPath: resourcePath)
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
