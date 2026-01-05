//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import AVFoundation
import Foundation

class CaptureSessionManagingMock: CaptureSessionManaging {

    // MARK: - delegate

    var delegate: CaptureSessionDelegate?

    // MARK: - videoPreviewLayer

    var videoPreviewLayer: AVCaptureVideoPreviewLayer = .init()

    // MARK: - requestCaptureAuthorization

    var requestCaptureAuthorizationCallsCount = 0
    var requestCaptureAuthorizationCalled: Bool {
        requestCaptureAuthorizationCallsCount > 0
    }

    var requestCaptureAuthorizationReturnValue: CaptureAuthorizationStatus = .authorized
    var requestCaptureAuthorizationClosure: (() async -> CaptureAuthorizationStatus)?

    func requestCaptureAuthorization() async -> CaptureAuthorizationStatus {
        requestCaptureAuthorizationCallsCount += 1
        if let closure = requestCaptureAuthorizationClosure {
            return await closure()
        } else {
            return requestCaptureAuthorizationReturnValue
        }
    }

    // MARK: - configureSession

    var configureSessionCallsCount = 0
    var configureSessionCalled: Bool {
        configureSessionCallsCount > 0
    }

    var configureSessionClosure: (() -> Void)?

    func configureSession() {
        configureSessionCallsCount += 1
        configureSessionClosure?()
    }

    // MARK: - startCaptureSession

    var startCaptureSessionCallsCount = 0
    var startCaptureSessionCalled: Bool {
        startCaptureSessionCallsCount > 0
    }

    var startCaptureSessionClosure: (() -> Void)?

    func startCaptureSession() {
        startCaptureSessionCallsCount += 1
        startCaptureSessionClosure?()
    }

    // MARK: - stopCaptureSession

    var stopCaptureSessionCallsCount = 0
    var stopCaptureSessionCalled: Bool {
        stopCaptureSessionCallsCount > 0
    }

    var stopCaptureSessionClosure: (() -> Void)?

    func stopCaptureSession() {
        stopCaptureSessionCallsCount += 1
        stopCaptureSessionClosure?()
    }

    // MARK: - updateVideoOrientation

    var updateVideoOrientationCallsCount = 0
    var updateVideoOrientationCalled: Bool {
        updateVideoOrientationCallsCount > 0
    }

    var updateVideoOrientationClosure: (() -> Void)?

    func updateVideoOrientation() {
        updateVideoOrientationCallsCount += 1
        updateVideoOrientationClosure?()
    }
}
