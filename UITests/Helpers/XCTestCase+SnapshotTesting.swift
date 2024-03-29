//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SnapshotTesting
import UIKit
import XCTest

extension XCTestCase {
    
    static var shouldRecordSnapshots: Bool { CommandLine.arguments.contains("-GenerateSnapshots") }
    
    func assertViewControllerImage(matching viewController: @autoclosure () throws -> UIViewController,
                                   named name: String,
                                   file: StaticString = #file,
                                   caller: String = #function,
                                   line: UInt = #line) {
        
        try SnapshotTesting.assertSnapshot(
            matching: viewController(),
            as: snapshotConfiguration(),
            named: name,
            record: XCTestCase.shouldRecordSnapshots,
            file: file,
            testName: testName(for: caller),
            line: line
        )
    }
    
    /// Verifies whether or not the snapshot of the view controller matches the previously recorded snapshot
    ///
    /// Multiple verification snapshots are taken within the timeout and compared with the reference snapshot
    func verifyViewControllerImage(matching viewController: @autoclosure () throws -> UIViewController,
                                   named name: String,
                                   record: Bool = false,
                                   timeout: TimeInterval = 120,
                                   file: StaticString = #file,
                                   caller: String = #function,
                                   line: UInt = #line) {
        
        if XCTestCase.shouldRecordSnapshots {
            // We're recording so we assert immediately
            // to not wait until it finally throws an error on the code below
            try assertViewControllerImage(
                matching: viewController(),
                named: name,
                file: file,
                caller: caller,
                line: line
            )
            
            return
        }
        
        wait(
            until: {
                let failure = try! verifySnapshot(
                    of: viewController(),
                    as: snapshotConfiguration(),
                    named: name,
                    file: file,
                    testName: testName(for: caller),
                    line: line
                )
                return failure == nil
            },
            timeout: timeout,
            retryInterval: .seconds(1),
            message: "Snapshot did not match reference (Timeout: \(timeout)s)"
        )
    }
    
}

extension XCTestCase {
    
    func testName(for callingFunction: String) -> String {
        let simulatorName = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "Unknown_Simulator"
        let systemName = UIDevice.current.systemName
        let versionName = UIDevice.current.systemVersion
        return "\(callingFunction)-\(simulatorName)-\(systemName)_\(versionName)"
    }
    
    func snapshotConfiguration() -> Snapshotting<UIViewController, UIImage> {
        let precision: Float = 0.98
        
        return .image(perceptualPrecision: precision)
    }
}
