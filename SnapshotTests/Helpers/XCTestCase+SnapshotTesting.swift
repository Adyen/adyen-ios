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
    
    enum SnapshotPrecision: Float {
        case `default` = 1.0
        /// Uses a lower precision as blurred content is a bit less precise to compare
        case blurredContent = 0.95
    }
    
    func assertViewControllerImage(
        matching viewController: @autoclosure () throws -> UIViewController,
        named name: String,
        file: StaticString = #file,
        caller: String = #function,
        line: UInt = #line
    ) {
        
        try SnapshotTesting.assertSnapshot(
            matching: viewController(),
            as: snapshotConfiguration(precision: .default),
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
    func verifyViewControllerImage(
        matching viewController: @autoclosure () throws -> UIViewController,
        named name: String,
        precision: SnapshotPrecision = .default,
        timeout: TimeInterval = 60,
        file: StaticString = #file,
        caller: String = #function,
        line: UInt = #line
    ) {
        
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
        
        let testName = testName(for: caller)
        
        wait(
            until: {
                let failure = try! verifySnapshot(
                    of: viewController(),
                    as: snapshotConfiguration(precision: precision),
                    named: name,
                    file: file,
                    testName: testName,
                    line: line
                )
                return failure == nil
            },
            timeout: timeout,
            retryInterval: .seconds(1),
            message: "Snapshot did not match reference (Timeout: \(timeout)s) - \(testName)"
        )
    }
    
}

extension XCTestCase {
    
    func testName(for callingFunction: String) -> String {
        let simulatorName = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "Unknown_Simulator"
        let systemName = UIDevice.current.systemName
        let versionName = UIDevice.current.systemVersion
        let locale = Locale.current.identifier
        return "\(callingFunction)-\(simulatorName)-\(systemName)_\(versionName)-\(locale)"
    }
    
    func snapshotConfiguration(precision: SnapshotPrecision) -> Snapshotting<UIViewController, UIImage> {
        .image(
            drawHierarchyInKeyWindow: true,
            perceptualPrecision: precision.rawValue
        )
    }
}
