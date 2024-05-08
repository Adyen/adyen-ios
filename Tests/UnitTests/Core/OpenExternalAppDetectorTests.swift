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
        
        // If the app is in background during the check 
        // -> an external app was opened
        verifyOpenExternalAppDetectionExpectation(
            applicationState: .background,
            didOpen: true
        )
        
        // If the app is inactive during the check 
        // -> an action was triggered that rendered system ui over the current app which indicates that an external action was triggered
        verifyOpenExternalAppDetectionExpectation(
            applicationState: .inactive,
            didOpen: false
        )
        
        // If the app is still in foreground during the check 
        // -> no external app was opened
        verifyOpenExternalAppDetectionExpectation(
            applicationState: .active,
            didOpen: false
        )
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
        
        let openAppDetector = OpenExternalAppDetector(applicationStateProvider: provider)
        openAppDetector.checkIfExternalAppDidOpen { didOpen in
            XCTAssertEqual(didOpen, expectedDidOpenOutput)
            didOpenExpectation.fulfill()
        }
        
        wait(for: [didOpenExpectation], timeout: 1)
    }
}
