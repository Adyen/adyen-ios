//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import Foundation
import QuartzCore

class CardScannerViewModelMock: CardScannerViewModelProtocol {
    // MARK: - videoPreviewLayer

    var videoPreviewLayer: CALayer = .init()

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

    // MARK: - update

    var updateCallsCount = 0
    var updateCalled: Bool {
        updateCallsCount > 0
    }

    var updateReceivedPreviewLayerFrame: CGRect?
    var updateReceivedROIInPreviewLayer: CGRect?
    var updateReceivedInvocations: [(CGRect, CGRect)] = []
    var updateClosure: ((CGRect, CGRect) -> Void)?

    func update(previewLayerFrame: CGRect, roiInPreviewLayer: CGRect) {
        updateCallsCount += 1
        updateReceivedPreviewLayerFrame = previewLayerFrame
        updateReceivedROIInPreviewLayer = roiInPreviewLayer
        updateReceivedInvocations.append((previewLayerFrame, roiInPreviewLayer))
        updateClosure?(previewLayerFrame, roiInPreviewLayer)
    }
}
