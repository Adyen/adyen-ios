//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 15/07/2024.
//

@testable import public_api_diff
import XCTest

class SDKDumpTests: XCTestCase {
    
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
        
        let expectedDefinition: String = "public static func foo(_: Swift.Int, bar: Swift.Double = $DEFAULT_ARG) -> Swift.Bool"
        
        XCTAssertEqual(
            dump.root.definition,
            expectedDefinition
        )
    }
    
    func test_isInternal() throws {
        // TODO: Implement
    }
    
    func test_spi() throws {
        // TODO: Implement
    }
}
