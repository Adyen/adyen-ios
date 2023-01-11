//
//  XCTestCaseExtensions.swift
//  AdyenUIHostUITests
//
//  Created by Mohamed Eldoheiri on 11/01/2023.
//  Copyright © 2023 Adyen. All rights reserved.
//

import UIKit
import XCTest
import SnapshotTesting

extension XCTestCase {
    
    func assertViewHeirarchy(matching viewController: @autoclosure () throws -> UIViewController,
                             named name: String,
                             file: StaticString = #file,
                             testName: String = #function,
                             line: UInt = #line) {
        SnapshotTesting.assertSnapshot(matching: try viewController(),
                                       as: .recursiveDescription(size: UIScreen.main.bounds.size),
                                       named: name,
                                       file: file,
                                       testName: testName,
                                       line: line)
    }
    
    func assertViewSnapshot(matching viewController: @autoclosure () throws -> UIViewController,
                            named name: String,
                            file: StaticString = #file,
                            testName: String = #function,
                            line: UInt = #line) {
        SnapshotTesting.assertSnapshot(matching: try viewController(),
                                       as: .image(drawHierarchyInKeyWindow: true, size: UIScreen.main.bounds.size),
                                       named: name,
                                       file: file,
                                       testName: testName,
                                       line: line)
    }
    
    func assertSnapshot(matching view: @autoclosure () throws -> UIView,
                        named name: String,
                        file: StaticString = #file,
                        testName: String = #function,
                        line: UInt = #line) {
        SnapshotTesting.assertSnapshot(matching: try view(),
                                       as: .image(drawHierarchyInKeyWindow: true, size: UIScreen.main.bounds.size),
                                       named: name,
                                       file: file,
                                       testName: testName,
                                       line: line)
    }
}
