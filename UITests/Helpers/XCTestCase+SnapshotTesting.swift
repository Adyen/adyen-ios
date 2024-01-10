//
//  XCTestCase+SnapshotTesting.swift
//  AdyenUIHostUITests
//
//  Created by Mohamed Eldoheiri on 11/01/2023.
//  Copyright © 2023 Adyen. All rights reserved.
//

import SnapshotTesting
import UIKit
import XCTest

extension XCTestCase {
    
    static var shouldRecordSnapshots: Bool = true
    
    func assertViewControllerImage(matching viewController: @autoclosure () throws -> UIViewController,
                                   named name: String,
                                   device: ViewImageConfig = .iPhone12,
                                   file: StaticString = #file,
                                   line: UInt = #line) {
        
        try SnapshotTesting.assertSnapshot(
            matching: viewController(),
            as: device.snapshotConfiguration,
            named: name,
            record: XCTestCase.shouldRecordSnapshots,
            file: file,
            testName: device.testName(for: name),
            line: line
        )
    }
    
    /// Verifies whether or not the snapshot of the view controller matches the previously recorded snapshot
    ///
    /// Multiple verification snapshots are taken within the timeout and compared with the reference snapshot
    func verifyViewControllerImage(matching viewController: @autoclosure () throws -> UIViewController,
                                   named name: String,
                                   timeout: TimeInterval = 120,
                                   device: ViewImageConfig = .iPhone12,
                                   file: StaticString = #file,
                                   line: UInt = #line) {
        
        if XCTestCase.shouldRecordSnapshots {
            // We're recording so we assert immediately
            // to not wait until it finally throws an error on the code below
            try assertViewControllerImage(
                matching: viewController(),
                named: name,
                device: device,
                file: file,
                line: line
            )
            
            return
        }
        
        wait(
            until: {
                let failure = try! verifySnapshot(
                  of: viewController(),
                  as: device.snapshotConfiguration,
                  named: name,
                  record: false,
                  file: file,
                  testName: device.testName(for: name),
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

extension ViewImageConfig {
    
    func testName(for testName: String) -> String {
        let name = "\(testName)-\(description)"
        print("⚠️", name)
        return name
    }
    
    var snapshotConfiguration: Snapshotting<UIViewController, UIImage> {
        .image(on: self, perceptualPrecision: 0.98)
    }
}

extension ViewImageConfig: CustomStringConvertible {
    public var description: String {
        switch self {
        case .iPhone12:
            return "iPhone12"
        case .iPhone13:
            return "iPhone13"
        case .iPhoneX:
            return "iPhoneX"
        case .iPhoneSe:
            return "iPhoneSe"
        case .iPad9_7:
            return "iPad9_7"
        case .iPadMini:
            return "iPadMini"
        case .iPhoneXr:
            return "iPhoneXr"
        case .iPadPro11:
            return "iPadPro11"
        case .iPhone12Pro:
            return "iPhone12Pro"
        case .iPhone13Pro:
            return "iPhone13Pro"
        case .iPhone8Plus:
            return "iPhone8Plus"
        case .iPhone13Mini:
            return "iPhone13Mini"
        case .iPhoneXsMax:
            return "iPhoneXsMax"
        case .iPhone12ProMax:
            return "iPhone12ProMax"
        case .iPhone13ProMax:
            return "iPhone13ProMax"
        case .iPad10_2:
            return "iPad10_2"
        case .iPadPro10_5:
            return "iPadPro10_5"
        case .iPadPro12_9:
            return "iPadPro12_9"
        case .iPhone8(.landscape):
            return "iPhone8-landscape"
        case .iPhone8(.portrait):
            return "iPhone8-portrait"
        case .iPhone12(.portrait):
            return "iPhone12-portrait"
        case .iPhone12(.landscape):
            return "iPhone12-landscape"
        case .iPhone13(.landscape):
            return "iPhone13-landscape"
        case .iPhone13(.portrait):
            return "iPhone13-portrait"
        case .iPhoneX(.portrait):
            return "iPhoneX-portrait"
        case .iPhoneX(.landscape):
            return "iPhoneX-landscape"
        case .iPhoneXr(.portrait):
            return "iPhoneXr-portrait"
        case .iPhoneX(.landscape):
            return "iPhoneXr-landscape"
        case .iPadMini(.portrait):
            return "iPadMini-portrait"
        case .iPadMini(.landscape):
            return "iPadMini-landscape"
        case .iPhoneSe(.portrait):
            return "iPhoneSe-portrait"
        case .iPhoneSe(.landscape):
            return "iPhoneSe-landscape"
        case .iPhone8Plus(.portrait):
            return "iPhone8Plus-portrait"
        case .iPhone8Plus(.landscape):
            return "iPhone8Plus-landscape"
        case .iPhone13Pro(.portrait):
            return "iPhone13Pro-portrait"
        case .iPhone13Pro(.landscape):
            return "iPhone13Pro-landscape"
        case .iPhone12Pro(.portrait):
            return "iPhone12Pro-portrait"
        case .iPhone12Pro(.landscape):
            return "iPhone12Pro-landscape"
        case .iPhone13Mini(.portrait):
            return "iPhone13Mini-portrait"
        case .iPhone13Mini(.landscape):
            return "iPhone13Mini-landscape"
        case .iPhoneXsMax(.portrait):
            return "iPhoneXsMax-portrait"
        case .iPhoneXsMax(.landscape):
            return "iPhoneXsMax-landscape"
        case .iPhone13ProMax(.portrait):
            return "iPhone13ProMax-portrait"
        case .iPhone13ProMax(.landscape):
            return "iPhone13ProMax-landscape"
        case .iPhone12ProMax(.portrait):
            return "iPhone12ProMax-portrait"
        case .iPhone12ProMax(.landscape):
            return "iPhone12ProMax-landscape"
        case .iPhone8(.portrait):
            return "iPhone8-portrait"
        case .iPhone8(.landscape):
            return "iPhone8-landscape"
        default:
            fatalError("Unknown device")
        }
    }
}

extension ViewImageConfig: Equatable {
    public static func == (lhs: ViewImageConfig, rhs: ViewImageConfig) -> Bool {
        lhs.size == rhs.size && lhs.safeArea == rhs.safeArea
    }
}
