//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import CoreImage
import AVFoundation
import UIKit

protocol CardScannerViewModelProtocol {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { get }

    func configureSession()
    func startSession()
    func stopSession()
    func updateVideoOrientation()
    func update(previewLayerFrame: CGRect, roiInPreviewLayer: CGRect)
}

class CardScannerViewModel: NSObject, CardScannerViewModelProtocol {

    // MARK: - Properties

    private let sessionQueue = DispatchQueue(label: "com.cardscanner.sessionQueue", qos: .userInitiated) // For session config
    private let videoOutputQueue = DispatchQueue(label: "com.cardscanner.videoOutputQueue") // For frame processing

    private let cardImageParser: CardImageParsing
    private let captureSession: AVCaptureSession
    private let captureDevice: AVCaptureDevice
    private(set) var videoPreviewLayer: AVCaptureVideoPreviewLayer

    private let completion: (Result<CreditCard, CardScannerError>) -> ()

    private var previewFrame: CGRect = .zero
    private var roiInPreviewFrame: CGRect = .zero

    // MARK: - Initializers

    init(
        cardImageParser: CardImageParsing,
        captureSession: AVCaptureSession,
        captureDevice: AVCaptureDevice,
        completion: @escaping (Result<CreditCard, CardScannerError>) -> ()
    ) {
        self.cardImageParser = cardImageParser
        self.captureSession = captureSession
        self.captureDevice = captureDevice
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.completion = completion
    }

    // MARK: - CardScannerViewModelProtocol

    func configureSession() {
        sessionQueue.async {
            self.configureCaptureSession()
        }
    }

    func startSession() {
        sessionQueue.async {
            guard !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async {
            guard self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }

    func update(previewLayerFrame: CGRect, roiInPreviewLayer: CGRect) {
        self.previewFrame = previewLayerFrame
        self.roiInPreviewFrame = roiInPreviewLayer
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

    private func configureCaptureSession() {
        captureSession.beginConfiguration()

        // Set up input
        guard
            let videoInput = try? AVCaptureDeviceInput(device: captureDevice),
            captureSession.canAddInput(videoInput)
        else {
            let cardScannerError = CardScannerError(kind: .capture)
            completion(.failure(cardScannerError))
            return
        }

        // Configure capture device settings
        configureCaptureDevice(captureDevice)

        captureSession.addInput(videoInput)

        // Set up output
        let videoOutput = AVCaptureVideoDataOutput()
        let videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        videoOutput.videoSettings = videoSettings
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)

        guard captureSession.canAddOutput(videoOutput) else {
            let cardScannerError = CardScannerError(kind: .capture)
            completion(.failure(cardScannerError))
            return
        }

        captureSession.addOutput(videoOutput)

        guard
            let connection = videoOutput.connection(with: .video),
            connection.isVideoStabilizationSupported else {
            let cardScannerError = CardScannerError(kind: .capture)
            completion(.failure(cardScannerError))
            return
        }
        connection.preferredVideoStabilizationMode = .auto

        captureSession.commitConfiguration()
    }

    private func configureCaptureDevice(_ device: AVCaptureDevice) {
        try? device.lockForConfiguration()

        // Adjust Frame Rate
        device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 15) // 15 fps
        device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 30) // 30 fps

        // Focus and Exposure Settings
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }

        // Auto Exposure
        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }

        // Lighting Conditions
        if device.hasTorch, device.isTorchModeSupported(.auto) {
            device.torchMode = .auto
        }

        device.unlockForConfiguration()
    }

    private func getCardData(
        from image: CIImage,
        roiInPreviewFrame: CGRect,
        previewFrame: CGRect
    ) {
        guard let croppedImage = cropRegionOfInterest(
            from: image,
            roiInPreviewFrame: roiInPreviewFrame,
            previewFrame: previewFrame
        ) else {
            return
        }

        cardImageParser.parse(image: croppedImage) { creditCard in
            self.completion(.success(creditCard))
        }
    }

    private func cropRegionOfInterest(from image: CIImage,
                                      roiInPreviewFrame: CGRect,
                                      previewFrame: CGRect) -> CIImage? {
        // Scale factors between CIImage and preview frame
        let imageWidth = image.extent.width
        let imageHeight = image.extent.height

        let previewWidth = previewFrame.width
        let previewHeight = previewFrame.height

        let scaleX = imageWidth / previewWidth
        let scaleY = imageHeight / previewHeight

        // Adjust for any potential aspect ratio difference
        let scaleFactor = max(scaleX, scaleY) // Use the larger factor to ensure full coverage

        // Adjust ROI to CIImage coordinates
        let scaledROI = CGRect(
            x: roiInPreviewFrame.origin.x * scaleFactor,
            y: roiInPreviewFrame.origin.y * scaleFactor,
            width: roiInPreviewFrame.width * scaleFactor,
            height: roiInPreviewFrame.height * scaleFactor
        )

        // Center the ROI if the aspect ratios differ
        let xOffset = (imageWidth - (previewWidth * scaleFactor)) * 0.5
        let yOffset = (imageHeight - (previewHeight * scaleFactor)) * 0.5

        let adjustedROI = CGRect(
            x: scaledROI.origin.x + xOffset,
            y: scaledROI.origin.y + yOffset,
            width: scaledROI.width,
            height: scaledROI.height
        )

        // Ensure the ROI is within the bounds of the CIImage
        let croppedROI = adjustedROI.intersection(image.extent)

        // Crop the CIImage using the ROI
        return image.cropped(to: croppedROI)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CardScannerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("Unable to get image from sample buffer")
            let cardScannerError = CardScannerError(kind: .photoProcessing)
            completion(.failure(cardScannerError))
            return
        }

        self.processImage(
            frame,
            previewLayerFrame: self.previewFrame,
            roiInPreviewLayer: self.roiInPreviewFrame
        )
    }

    // MARK: - Private

    private func processImage(_ frame: CVImageBuffer,
                              previewLayerFrame: CGRect,
                              roiInPreviewLayer: CGRect) {
        let image = CIImage(cvImageBuffer: frame)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.getCardData(
                from: image,
                roiInPreviewFrame: roiInPreviewLayer,
                previewFrame: previewLayerFrame
            )
        }
    }
}

extension AVCaptureVideoOrientation {

    static var currentVideoOrientation: AVCaptureVideoOrientation {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            return .portrait
        case .landscapeRight:
            return .landscapeLeft // Camera flips the orientation
        case .landscapeLeft:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait // Default to portrait if unknown
        }
    }
}
