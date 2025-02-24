//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import AVFoundation
import CoreImage

protocol CaptureSessionDelegate: AnyObject {
    func didCapture(image: CIImage?)
}

protocol CaptureSessionManaging {
    var delegate: CaptureSessionDelegate? { get set }
    func configureSession()
    func startCaptureSession()
    func stopCaptureSession()
    func updateVideoOrientation()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { get }
}

class CaptureSessionManager: NSObject, CaptureSessionManaging {

    enum Constants {
        static let videoSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        static let captureDeviceMinFrameDuration = CMTime(value: 1, timescale: 15) // 15 fps
        static let captureDeviceMaxFrameDuration = CMTime(value: 1, timescale: 30) // 30 fps
    }

    // MARK: - Properties

    private let sessionQueue = DispatchQueue(label: "com.cardscanner.sessionQueue", qos: .userInitiated)
    private let videoOutputQueue = DispatchQueue(label: "com.cardscanner.videoOutputQueue")

    private let captureDevice: AVCaptureDevice
    let videoPreviewLayer: AVCaptureVideoPreviewLayer
    weak var delegate: CaptureSessionDelegate?

    private let captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()

    // MARK: - Initializers

    init(captureDevice: AVCaptureDevice) {
        self.captureDevice = captureDevice

        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
    }

    // MARK: - CaptureSessionManaging

    func configureSession() {
        sessionQueue.async {
            try? self.configureCaptureSession()
        }
    }

    func startCaptureSession() {
        sessionQueue.async {
            guard !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }

    func stopCaptureSession() {
        sessionQueue.async {
            guard self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }

    func updateVideoOrientation() {
        guard
            let connection = videoPreviewLayer.connection,
            connection.isVideoOrientationSupported else {
            return
        }

        connection.videoOrientation = .currentVideoOrientation
        videoPreviewLayer.removeAllAnimations()
    }

    // MARK: - Private

    private func configureCaptureSession() throws {
        captureSession.beginConfiguration()

        guard
            let videoInput = try? AVCaptureDeviceInput(device: captureDevice),
            captureSession.canAddInput(videoInput)
        else {
            throw CardScannerError(kind: .capture)
        }

        configureCaptureDevice(captureDevice)

        captureSession.addInput(videoInput)

        let videoOutput = AVCaptureVideoDataOutput()
        let videoSettings = Constants.videoSettings
        videoOutput.videoSettings = videoSettings
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)

        guard captureSession.canAddOutput(videoOutput) else {
            let cardScannerError = CardScannerError(kind: .capture)
            throw cardScannerError
        }

        captureSession.addOutput(videoOutput)

        guard
            let connection = videoOutput.connection(with: .video),
            connection.isVideoStabilizationSupported else {
            let cardScannerError = CardScannerError(kind: .capture)
            throw cardScannerError
        }
        connection.preferredVideoStabilizationMode = .auto

        captureSession.commitConfiguration()
    }

    private func configureCaptureDevice(_ device: AVCaptureDevice) {
        try? device.lockForConfiguration()

        device.activeVideoMinFrameDuration = Constants.captureDeviceMinFrameDuration
        device.activeVideoMaxFrameDuration = Constants.captureDeviceMaxFrameDuration

        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }

        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }

        device.unlockForConfiguration()
    }
}

extension CaptureSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let image = CIImage(cvImageBuffer: imageBuffer)
            delegate?.didCapture(image: image)
        } else {
            delegate?.didCapture(image: nil)
        }
    }
}
