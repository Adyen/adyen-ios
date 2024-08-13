//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class SDKDumpAnalyzerTests: XCTestCase {
    
    func test_noChanges() throws {
        
        let newDump = SDKDump(root: .init(kind: .var, name: "name", printedName: "printedName"))
        
        let expectedChanges: [Change] = []
        
        let analyzer = SDKDumpAnalyzer()
        let changes = analyzer.analyze(old: newDump, new: newDump)
        
        XCTAssertEqual(changes, expectedChanges)
    }
    
    func test_rootChanged() throws {
        
        let newDump = SDKDump(root: .init(kind: .var, name: "name", printedName: "printedName"))
        let oldDump = SDKDump(root: .init(kind: .func, name: "old_name", printedName: "old_printedName"))
        
        let expectedChanges: [Change] = [
            .init(changeType: .removal(description: "public old_printedName"), parentName: ""),
            .init(changeType: .addition(description: "public printedName"), parentName: "")
        ]
        
        let analyzer = SDKDumpAnalyzer()
        let changes = analyzer.analyze(
            old: oldDump,
            new: newDump
        )
        
        XCTAssertEqual(changes, expectedChanges)
    }
    
    func test_childChange() throws {
        
        let oldDump = SDKDump(
            root: .init(
                kind: .var,
                name: "parent",
                printedName: "printedName"
            )
        )
        
        let newDump = SDKDump(
            root: .init(
                kind: .var,
                name: "parent",
                printedName: "printedName",
                children: [.init(
                    kind: .var,
                    name: "child",
                    printedName: "childPrintedName"
                )]
            )
        )
        
        // Adding Child
        
        let expectedChangesAdded: [Change] = [
            .init(changeType: .addition(description: "public childPrintedName"), parentName: "parent")
        ]
        
        let analyzer = SDKDumpAnalyzer()
        let changesAdded = analyzer.analyze(
            old: oldDump,
            new: newDump
        )
        
        XCTAssertEqual(changesAdded, expectedChangesAdded)
        
        // Removing Child
        
        let expectedChangesRemoved: [Change] = [
            .init(changeType: .removal(description: "public childPrintedName"), parentName: "parent")
        ]
        
        let changesRemoved = analyzer.analyze(
            old: newDump,
            new: oldDump
        )
        
        XCTAssertEqual(changesRemoved, expectedChangesRemoved)
    }
    
    func test_deepHierarchyChange() throws {
        
        let oldDump = SDKDump(
            root: .init(
                kind: .class,
                name: "parent",
                printedName: "printedName",
                declKind: .class,
                children: [
                    .init(kind: .struct, name: "child", printedName: "childPrintedName", declKind: .struct),
                    .init(kind: .class, name: "spiChild", printedName: "spiChildPrintedName", declKind: .class),
                    .init(kind: .class, name: "invisibleSpiChild", printedName: "invisibleSpiChildPrintedName", declKind: .class, spiGroupNames: ["SpiInternal"]),
                    .init(kind: .enum, name: "enumChild", printedName: "new_childPrintedName", declKind: .enum, children: [
                        .init(kind: .var, name: "staticLet", printedName: "staticLetPrintedName", declKind: .var, isStatic: true, isLet: false),
                        .init(kind: .case, name: "someCase", printedName: "someCasePrintedName", declKind: .case),
                        .init(kind: .case, name: "oldCase", printedName: "oldCasePrintedName", declKind: .case)
                    ])
                ]
            )
        )
        
        let newDump = SDKDump(
            root: .init(
                kind: .class,
                name: "parent",
                printedName: "printedName",
                declKind: .class,
                children: [
                    .init(kind: .class, name: "child", printedName: "childPrintedName", declKind: .class),
                    .init(kind: .class, name: "spiChild", printedName: "spiChildPrintedName", declKind: .class, spiGroupNames: ["SpiInternal"]),
                    .init(kind: .class, name: "invisibleSpiChild", printedName: "invisibleSpiChildPrintedName", declKind: .class, children: [
                        .init(kind: .var, name: "name", printedName: "printedName")
                    ], spiGroupNames: ["SpiInternal"]),
                    .init(kind: .enum, name: "enumChild", printedName: "new_childPrintedName", declKind: .enum, children: [
                        .init(kind: .var, name: "staticLet", printedName: "staticLetPrintedName", declKind: .var, isStatic: true, isLet: true),
                        .init(kind: .case, name: "someCase", printedName: "someCasePrintedName", declKind: .case),
                        .init(kind: .case, name: "newCase", printedName: "newCasePrintedName", declKind: .case)
                    ])
                ]
            )
        )
        
        let expectedChanges: [Change] = [
            .init(changeType: .removal(description: "public struct childPrintedName"), parentName: "parent"),
            .init(changeType: .removal(description: "public class spiChildPrintedName"), parentName: "parent"),
            .init(changeType: .change(oldDescription: "public static var staticLetPrintedName", newDescription: "public static let staticLetPrintedName"), parentName: "parent.enumChild"),
            .init(changeType: .removal(description: "public case oldCasePrintedName"), parentName: "parent.enumChild"),
            .init(changeType: .addition(description: "public class childPrintedName"), parentName: "parent"),
            .init(changeType: .addition(description: "public case newCasePrintedName"), parentName: "parent.enumChild")
        ]
        
        let analyzer = SDKDumpAnalyzer()
        let changes = analyzer.analyze(
            old: oldDump,
            new: newDump
        )

        XCTAssertEqual(expectedChanges.count, changes.count)
        changes.enumerated().forEach { index, change in
            let expectedChange = expectedChanges[index]
            XCTAssertEqual(change, expectedChange)
        }
    }
    
    /*
     func test_targetChange() throws {
        
         let dump = SDKDump(
             root: .init(
                 kind: "kind",
                 name: "parent",
                 printedName: "printedName"
             )
         )
        
         // Adding Target
        
         let expectedChangesAdded: [Change] = [
             .init(changeType: .addition, parentName: "", changeDescription: "Target was added")
         ]
        
         let analyzer = SDKDumpAnalyzer()
         let changes = analyzer.analyze(
             old: nil,
             new: dump
         )

         XCTAssertEqual(changesAdded, expectedChangesAdded)
        
         // Removing Target
        
         let expectedChangesRemoved: [Change] = [
             .init(changeType: .removal, parentName: "", changeDescription: "Target was removed")
         ]
        
         let changesRemoved = analyzer.analyze(
             old: dump,
             new: nil
         )
        
         XCTAssertEqual(changesRemoved, expectedChangesRemoved)
     }
      */
}
