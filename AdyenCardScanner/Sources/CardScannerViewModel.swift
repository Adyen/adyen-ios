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
    func viewDidLoad()
    func viewWillAppear()
    func viewDidDisappear()
    var videoPreviewLayer: CALayer { get }
    func update(previewLayerFrame: CGRect, roiInPreviewLayer: CGRect)
}

class CardScannerViewModel: NSObject, CardScannerViewModelProtocol {

    // MARK: - Properties

    private let cardImageParser: CardImageParsing
    private let captureSession: AVCaptureSession
    private let captureDevice: AVCaptureDevice

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
        self.completion = completion
    }

    // MARK: - CardScannerViewModelProtocol

    func viewDidLoad() {
        self.setupCaptureDevice()
        self.setupCaptureSession()
    }

    func viewWillAppear() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func viewDidDisappear() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    var videoPreviewLayer: CALayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }

    func update(previewLayerFrame: CGRect, roiInPreviewLayer: CGRect) {
        debugPrint("Preview layer frame: \(previewLayerFrame)")
        debugPrint("ROI layer frame: \(roiInPreviewLayer)")

        self.previewFrame = previewLayerFrame
        self.roiInPreviewFrame = roiInPreviewLayer
    }

    // MARK: - Private

    private func setupCaptureDevice() {
        try? captureDevice.lockForConfiguration()

        // Adjust Frame Rate
        captureDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 15) // 15 fps
        captureDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 30) // 30 fps

        // Focus and Exposure Settings
        if captureDevice.isFocusModeSupported(.continuousAutoFocus) {
            captureDevice.focusMode = .continuousAutoFocus
        }

        // Auto Exposure
        if captureDevice.isExposureModeSupported(.continuousAutoExposure) {
            captureDevice.exposureMode = .continuousAutoExposure
        }

        // Lighting Conditions
        if captureDevice.hasTorch, captureDevice.isTorchModeSupported(.auto) {
            captureDevice.torchMode = .auto
        }

        captureDevice.unlockForConfiguration()
    }

    private func setupCaptureSession() {
        captureSession.beginConfiguration()

        // Set up input
        do {
            let videoInput = try AVCaptureDeviceInput(device: captureDevice)

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                let cardScannerError = CardScannerError(kind: .capture)
                completion(.failure(cardScannerError))
                return
            }
        } catch {
            let cardScannerError = CardScannerError(kind: .capture, underlyingError: error)
            completion(.failure(cardScannerError))
            return
        }

        // Set up output
        let videoOutput = AVCaptureVideoDataOutput()
        let videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        videoOutput.videoSettings = videoSettings
        let videoQueue = DispatchQueue(label: "my.image.handling.queue")
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            let cardScannerError = CardScannerError(kind: .capture)
            completion(.failure(cardScannerError))
            return
        }

        guard let connection = videoOutput.connection(with: AVMediaType.video), connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = currentVideoOrientation

        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            } else {
                let cardScannerError = CardScannerError(kind: .capture)
                completion(.failure(cardScannerError))
                return
            }
        }

        captureSession.commitConfiguration()
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

    private var currentVideoOrientation: AVCaptureVideoOrientation {
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
