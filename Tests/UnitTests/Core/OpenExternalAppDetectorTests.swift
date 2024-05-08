//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@testable import AdyenActions
import XCTest

class OpenExternalAppDetectorTests: XCTestCase {
    
    func test_didOpen_shouldRespectApplicationState() {
        
        // If the app is (still) in foreground during the check
        // -> no external app was opened
        verifyOpenExternalAppDetectionExpectation(
            applicationState: .active,
            didOpen: false
        )
        
        // If the app is inactive during the check
        // -> an external app was opened (the app changes to "inactive" before it goes into "background")
        verifyOpenExternalAppDetectionExpectation(
            applicationState: .inactive,
            didOpen: false
        )
        
        // If the app is in background during the check
        // -> an external app was opened
        verifyOpenExternalAppDetectionExpectation(
            applicationState: .background,
            didOpen: true
        )
    }
    
    func test_defaultDetectionDelay_shouldBeOneSecond() throws {
        let openAppDetector = OpenExternalAppDetector()
        let expectedDate = try XCTUnwrap(Calendar.current.date(byAdding: .second, value: 1, to: Date()))
        
        let didOpenExpectation = expectation(description: "checkIfExternalAppDidOpen is called")
        
        openAppDetector.checkIfExternalAppDidOpen { _ in
            let comparisonResult = Calendar.current.compare(expectedDate, to: Date(), toGranularity: .second)
            XCTAssertEqual(comparisonResult, .orderedSame)
            didOpenExpectation.fulfill()
        }
        
        wait(for: [didOpenExpectation], timeout: 1)
    }
    
    func test_customDetectionDelay() throws {
        let openAppDetector = OpenExternalAppDetector(detectionDelay: .seconds(0))
        let expectedDate = Date()
        
        let didOpenExpectation = expectation(description: "checkIfExternalAppDidOpen is called")
        
        openAppDetector.checkIfExternalAppDidOpen { _ in
            let comparisonResult = Calendar.current.compare(expectedDate, to: Date(), toGranularity: .second)
            XCTAssertEqual(comparisonResult, .orderedSame)
            didOpenExpectation.fulfill()
        }
        
        wait(for: [didOpenExpectation], timeout: 1)
    }
}

// MARK: - Convenience

extension OpenExternalAppDetectorTests {
    
    func verifyOpenExternalAppDetectionExpectation(
        applicationState: UIApplication.State,
        didOpen expectedDidOpenOutput: Bool
    ) {
        struct MockApplicationStateProvider: ApplicationStateProviding {
            var applicationState: UIApplication.State
        }
        
        let provider = MockApplicationStateProvider(applicationState: applicationState)
        
        let didOpenExpectation = expectation(description: "checkIfExternalAppDidOpen is called")
        
        let openAppDetector = OpenExternalAppDetector(
            applicationStateProvider: provider,
            detectionDelay: .nanoseconds(0)
        )
        
        openAppDetector.checkIfExternalAppDidOpen { didOpen in
            XCTAssertEqual(didOpen, expectedDidOpenOutput)
            didOpenExpectation.fulfill()
        }
        
        wait(for: [didOpenExpectation], timeout: 1)
    }
}
