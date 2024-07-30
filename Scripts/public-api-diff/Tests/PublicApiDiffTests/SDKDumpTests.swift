//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class SDKDumpTests: XCTestCase {
    
    // MARK: - Default Args
    
    func test_staticFuncWithDefaultArgs() throws {
        
        let dump = SDKDump(
            root: .init(
                kind: .func,
                name: "name",
                printedName: "foo(_:bar:)",
                declKind: .func,
                isStatic: true,
                isLet: false,
                children: [
                    .init(kind: .typeNominal, name: "ReturnValue", printedName: "Swift.Bool"), // Return value
                    .init(kind: .typeNominal, name: "FirstParameter", printedName: "Swift.Int"), // 1st parameter
                    .init(kind: .typeNominal, name: "SecondParameter", printedName: "Swift.Double", hasDefaultArg: true) // 2nd parameter
                ]
            )
        )
        
        let expectedDefinition = "public static func foo(_: Swift.Int, bar: Swift.Double = $DEFAULT_ARG) -> Swift.Bool"
        
        XCTAssertEqual(
            dump.root.description,
            expectedDefinition
        )
    }
    
    func test_staticFuncWithDefaultArgs_missingArgs() throws {
        
        let dump = SDKDump(
            root: .init(
                kind: .func,
                name: "name",
                printedName: "foo(_:bar:)",
                declKind: .func,
                isStatic: true,
                isLet: false,
                children: [
                    .init(kind: .typeNominal, name: "ReturnValue", printedName: "Swift.Bool"), // Return value
                    .init(kind: .typeNominal, name: "FirstParameter", printedName: "Swift.Int") // 1st parameter
                ]
            )
        )
        
        let expectedDefinition = "public static func foo(_: Swift.Int, bar) -> Swift.Bool"
        
        XCTAssertEqual(
            dump.root.description,
            expectedDefinition
        )
    }
    
    // MARK: - isInternal
    
    func test_isInternal() throws {
        
        let dump = SDKDump(
            root: .init(
                kind: .func,
                name: "name",
                printedName: "foo(_:)",
                declKind: .func,
                isStatic: true,
                isLet: false,
                isInternal: true,
                children: [
                    .init(kind: .typeNominal, name: "ReturnValue", printedName: "Swift.Bool"), // Return value
                    .init(kind: .typeNominal, name: "FirstParameter", printedName: "Swift.Int") // 1st parameter
                ]
            )
        )
        
        let expectedDefinition = "internal static func foo(_: Swift.Int) -> Swift.Bool"
        
        XCTAssertEqual(
            dump.root.description,
            expectedDefinition
        )
    }
    
    // MARK: - spi
    
    func test_spi() throws {
        
        let dump = SDKDump(
            root: .init(
                kind: .func,
                name: "name",
                printedName: "foo(_:)",
                declKind: .func,
                isStatic: true,
                isLet: false,
                children: [
                    .init(kind: .typeNominal, name: "ReturnValue", printedName: "Swift.Bool"), // Return value
                    .init(kind: .typeNominal, name: "FirstParameter", printedName: "Swift.Int") // 1st parameter
                ], spiGroupNames: [
                    "Internal1",
                    "Internal2",
                    "Internal3"
                ]
            )
        )
        
        let expectedDefinition = "@_spi(Internal1) @_spi(Internal2) @_spi(Internal3) public static func foo(_: Swift.Int) -> Swift.Bool"
        
        XCTAssertEqual(
            dump.root.description,
            expectedDefinition
        )
    }
}
