//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AVFoundation
import CoreImage
import Foundation

internal enum CaptureAuthorizationStatus {
    case authorized
    case rejected
    case denied
}

internal protocol CaptureSessionDelegate: AnyObject {
    func didCapture(image: CIImage?)
}

@available(iOS 13.0, *)
internal protocol CaptureSessionManaging {
    var delegate: CaptureSessionDelegate? { get set }
    func requestCaptureAuthorization() async -> CaptureAuthorizationStatus
    func configureSession()
    func startCaptureSession()
    func stopCaptureSession()
    func updateVideoOrientation()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { get }
}

@available(iOS 13.0, *)
internal class CaptureSessionManager: NSObject, CaptureSessionManaging {

    private enum Constants {
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
    internal let videoPreviewLayer: AVCaptureVideoPreviewLayer
    internal weak var delegate: CaptureSessionDelegate?

    private let captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        return session
    }()

    // MARK: - Initializers

    internal init(captureDevice: AVCaptureDevice) {
        self.captureDevice = captureDevice

        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
    }

    // MARK: - CaptureSessionManaging

    internal func requestCaptureAuthorization() async -> CaptureAuthorizationStatus {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch authorizationStatus {
        case .authorized:
            return .authorized
        case .notDetermined:
            let isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            return isAuthorized ? .authorized : .rejected
        case .restricted, .denied:
            return .denied
        @unknown default:
            return .denied
        }
    }

    internal func configureSession() {
        sessionQueue.async {
            try? self.configureCaptureSession()
        }
    }

    internal func startCaptureSession() {
        sessionQueue.async {
            guard !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }

    internal func stopCaptureSession() {
        sessionQueue.async {
            guard self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }

    internal func updateVideoOrientation() {
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
        do {
            try device.lockForConfiguration()

            device.activeVideoMinFrameDuration = Constants.captureDeviceMinFrameDuration
            device.activeVideoMaxFrameDuration = Constants.captureDeviceMaxFrameDuration

            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }

            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }

            device.unlockForConfiguration()
        } catch {
            // Intentional empty error handling.
            // The card scanning can continue even if the capture device is not configured.
        }
    }
}

@available(iOS 13.0, *)
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
