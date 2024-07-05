//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class SDKDumpAnalyzerTests: XCTestCase {
    
    func test_noChanges() throws {
        
        let newDump = SDKDump(root: .init(kind: "kind", name: "name", printedName: "printedName"))
        
        let expectedChanges: [SDKAnalyzer.Change] = []
        
        let changes = try SDKDumpAnalyzer.analyzeSdkDump(
            newDump: newDump,
            oldDump: newDump
        )
        
        XCTAssertEqual(changes, expectedChanges)
    }
    
    func test_rootChanged() throws {
        
        let oldDump = SDKDump(root: .init(kind: "kind", name: "name", printedName: "printedName"))
        let newDump = SDKDump(root: .init(kind: "old_kind", name: "old_name", printedName: "old_printedName"))
        
        let expectedChanges: [SDKAnalyzer.Change] = [
            .init(changeType: .change, parentName: "", changeDescription: "`public printedName`\n  ➡️  `public old_printedName`")
        ]
        
        let changes = try SDKDumpAnalyzer.analyzeSdkDump(
            newDump: newDump,
            oldDump: oldDump
        )
        
        XCTAssertEqual(changes, expectedChanges)
    }
    
    func test_childChange() throws {
        
        let oldDump = SDKDump(
            root: .init(
                kind: "kind",
                name: "parent",
                printedName: "printedName"
            )
        )
        
        let newDump = SDKDump(
            root: .init(
                kind: "kind",
                name: "parent",
                printedName: "printedName",
                children: [.init(
                    kind: "kind",
                    name: "child",
                    printedName: "childPrintedName"
                )]
            )
        )
        
        // Adding Child
        
        let expectedChangesAdded: [SDKAnalyzer.Change] = [
            .init(changeType: .addition, parentName: "parent", changeDescription: "`public childPrintedName` was added")
        ]
        
        let changesAdded = try SDKDumpAnalyzer.analyzeSdkDump(
            newDump: newDump,
            oldDump: oldDump
        )
        
        XCTAssertEqual(changesAdded, expectedChangesAdded)
        
        // Removing Child
        
        let expectedChangesRemoved: [SDKAnalyzer.Change] = [
            .init(changeType: .removal, parentName: "parent", changeDescription: "`public childPrintedName` was removed")
        ]
        
        let changesRemoved = try SDKDumpAnalyzer.analyzeSdkDump(
            newDump: oldDump,
            oldDump: newDump
        )
        
        XCTAssertEqual(changesRemoved, expectedChangesRemoved)
    }
    
    func test_deepHierarchyChange() throws {
        
        let oldDump = SDKDump(
            root: .init(
                kind: "Class",
                name: "parent",
                printedName: "printedName",
                declKind: .classDeclaration,
                children: [
                    .init(kind: "Struct", name: "child", printedName: "childPrintedName", declKind: .structDelcaration),
                    .init(kind: "Class", name: "spiChild", printedName: "spiChildPrintedName", declKind: .classDeclaration),
                    .init(kind: "Class", name: "spiChild", printedName: "invisibleSpiChildPrintedName", declKind: .classDeclaration, spiGroupNames: ["SpiInternal"]),
                    .init(kind: "Enum", name: "enumChild", printedName: "new_childPrintedName", declKind: .enumDeclaration, children: [
                        .init(kind: "StaticLet", name: "staticLet", printedName: "staticLetPrintedName", declKind: .varDeclaration, isStatic: true, isLet: false),
                        .init(kind: "EnumElement", name: "someCase", printedName: "someCasePrintedName", declKind: .enumElement),
                        .init(kind: "EnumElement", name: "oldCase", printedName: "oldCasePrintedName", declKind: .enumElement)
                    ])
                ]
            )
        )
        
        let newDump = SDKDump(
            root: .init(
                kind: "Class",
                name: "parent",
                printedName: "printedName",
                declKind: .classDeclaration,
                children: [
                    .init(kind: "Class", name: "child", printedName: "childPrintedName", declKind: .classDeclaration),
                    .init(kind: "Class", name: "spiChild", printedName: "spiChildPrintedName", declKind: .classDeclaration, spiGroupNames: ["SpiInternal"]),
                    .init(kind: "Class", name: "spiChild", printedName: "invisibleSpiChildPrintedName", declKind: .classDeclaration, children: [
                        .init(kind: "kind", name: "name", printedName: "printedName")
                    ], spiGroupNames: ["SpiInternal"]),
                    .init(kind: "Enum", name: "enumChild", printedName: "new_childPrintedName", declKind: .enumDeclaration, children: [
                        .init(kind: "StaticLet", name: "staticLet", printedName: "staticLetPrintedName", declKind: .varDeclaration, isStatic: true, isLet: true),
                        .init(kind: "EnumElement", name: "someCase", printedName: "someCasePrintedName", declKind: .enumElement),
                        .init(kind: "EnumElement", name: "newCase", printedName: "newCasePrintedName", declKind: .enumElement)
                    ])
                ]
            )
        )
        
        let expectedChanges: [SDKAnalyzer.Change] = [
            .init(changeType: .change, parentName: "parent", changeDescription: "`public struct childPrintedName`\n  ➡️  `public class childPrintedName`"),
            .init(changeType: .change, parentName: "parent", changeDescription: "`public class spiChildPrintedName`\n  ➡️  `@_spi(SpiInternal) public class spiChildPrintedName`"),
            .init(changeType: .change, parentName: "parent.enumChild", changeDescription: "`public static var staticLetPrintedName`\n  ➡️  `public static let staticLetPrintedName`"),
            .init(changeType: .removal, parentName: "parent.enumChild", changeDescription: "`public case oldCasePrintedName` was removed"),
            .init(changeType: .addition, parentName: "parent.enumChild", changeDescription: "`public case newCasePrintedName` was added")
        ]
        
        let changes = try SDKDumpAnalyzer.analyzeSdkDump(
            newDump: newDump,
            oldDump: oldDump
        )

        XCTAssertEqual(changes, expectedChanges)
    }
    
    func test_targetChange() throws {
        
        let dump = SDKDump(
            root: .init(
                kind: "kind",
                name: "parent",
                printedName: "printedName"
            )
        )
        
        // Adding Target
        
        let expectedChangesAdded: [SDKAnalyzer.Change] = [
            .init(changeType: .addition, parentName: "", changeDescription: "Target was added")
        ]
        
        let changesAdded = try SDKDumpAnalyzer.analyzeSdkDump(
            newDump: dump,
            oldDump: nil
        )

        XCTAssertEqual(changesAdded, expectedChangesAdded)
        
        // Removing Target
        
        let expectedChangesRemoved: [SDKAnalyzer.Change] = [
            .init(changeType: .removal, parentName: "", changeDescription: "Target was removed")
        ]
        
        let changesRemoved = try SDKDumpAnalyzer.analyzeSdkDump(
            newDump: nil,
            oldDump: dump
        )
        
        XCTAssertEqual(changesRemoved, expectedChangesRemoved)
    }
}
