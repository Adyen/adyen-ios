//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import Foundation

class CardScannerPresentingMock: CardScannerPresenting {
    // MARK: - dismiss

    var dismissCallsCount = 0
    var dismissCalled: Bool {
        dismissCallsCount > 0
    }

    var dismissClosure: (() -> Void)?

    func dismiss() {
        dismissCallsCount += 1
        dismissClosure?()
    }

    // MARK: - presentCameraAccessDeniedAlert

    var presentCameraAccessDeniedAlertCallsCount = 0
    var presentCameraAccessDeniedAlertCalled: Bool {
        presentCameraAccessDeniedAlertCallsCount > 0
    }

    var presentCameraAccessDeniedAlertClosure: (() -> Void)?

    func presentCameraAccessDeniedAlert() {
        presentCameraAccessDeniedAlertCallsCount += 1
        presentCameraAccessDeniedAlertClosure?()
    }
}
