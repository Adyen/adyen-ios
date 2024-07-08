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
        
        let mockShell = MockShell { _ in
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
        
        let mockShell = MockShell { _ in
            return ""
        }
        
        var mockFileHandler = MockFileHandler()
        mockFileHandler.handleLoadData = { path in
            if path.range(of: "api_dump_") != nil {
                if path.range(of: "NewPackage") != nil {
                    // New
                    let newAbi = SDKDump(
                        root: .init(
                            kind: "Root",
                            name: "TopLevel",
                            printedName: "TopLevel",
                            children: [
                                .init(kind: "Function", name: "FunctionName", printedName: "handle(_:)", declKind: .funcDeclaration , children: [
                                    .init(kind: "TypeNominal", name: "String", printedName: "String"),
                                    .init(kind: "TypeNominal", name: "NewAction", printedName: "NewAction")
                                ]),
                                .init(kind: "Function", name: "FunctionName", printedName: "handle(_:)", declKind: .funcDeclaration , children: [
                                    .init(kind: "TypeNominal", name: "String", printedName: "String"),
                                    .init(kind: "TypeNominal", name: "SomeAction", printedName: "SomeAction")
                                ]),
                                .init(kind: "Function", name: "FunctionName", printedName: "handle(_:)", declKind: .funcDeclaration , children: [
                                    .init(kind: "TypeNominal", name: "String", printedName: "String"),
                                    .init(kind: "TypeNominal", name: "AnotherAction", printedName: "AnotherAction")
                                ])
                            ]
                        )
                    )
                    let abiJson = try JSONEncoder().encode(newAbi)
                    print(String(data: abiJson, encoding: .utf8)!)
                    return abiJson
                } else {
                    // Old
                    let oldAbi = SDKDump(
                        root: .init(
                            kind: "Root",
                            name: "TopLevel",
                            printedName: "TopLevel",
                            children: [
                                .init(kind: "Function", name: "FunctionName", printedName: "handle(_:)", declKind: .funcDeclaration, children: [
                                    .init(kind: "TypeNominal", name: "String", printedName: "String"),
                                    .init(kind: "TypeNominal", name: "OldAction", printedName: "OldAction")
                                ]),
                                .init(kind: "Function", name: "FunctionName", printedName: "handle(_:)", declKind: .funcDeclaration, children: [
                                    .init(kind: "TypeNominal", name: "String", printedName: "String"),
                                    .init(kind: "TypeNominal", name: "SomeAction", printedName: "SomeAction")
                                ]),
                                .init(kind: "Function", name: "FunctionName", printedName: "handle(_:)", declKind: .funcDeclaration, children: [
                                    .init(kind: "TypeNominal", name: "String", printedName: "String"),
                                    .init(kind: "TypeNominal", name: "AnotherAction", printedName: "AnotherAction")
                                ])
                            ]
                        )
                    )
                    let abiJson = try JSONEncoder().encode(oldAbi)
                    print(String(data: abiJson, encoding: .utf8)!)
                    return abiJson
                }
            }
            
            // We're only using the NewPackage definition to only check for code changes, not package changes
            let resourcePath = try XCTUnwrap(Bundle.module.path(forResource: "NewPackage", ofType: "txt"))
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
            "Adyen":
                [
                    SDKAnalyzer.Change.init(
                        changeType: .removal,
                        parentName: "",
                        changeDescription: "`public func handle(_: OldAction) -> String` was removed"
                    ),
                    SDKAnalyzer.Change.init(
                        changeType: .addition,
                        parentName: "",
                        changeDescription: "`public func handle(_: NewAction) -> String` was added"
                    )],
            "TargetWithBinaryDependency":
                [
                    SDKAnalyzer.Change.init(
                        changeType: .removal,
                        parentName: "",
                        changeDescription: "`public func handle(_: OldAction) -> String` was removed"
                    ),
                    SDKAnalyzer.Change.init(
                        changeType: .addition,
                        parentName: "",
                        changeDescription: "`public func handle(_: NewAction) -> String` was added"
                    )]
        ]
        
        let changes = try analyzer.analyze(
            old: "OldPackage",
            new: "NewPackage"
        )
        
        XCTAssertEqual(changes, expectedChanges)
    }
}
