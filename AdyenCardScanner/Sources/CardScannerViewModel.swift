//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CoreImage
import Foundation
import QuartzCore

internal protocol CardScannerViewModelProtocol {
    var videoPreviewLayer: CALayer { get }
    func configureSession()
    func startCaptureSession()
    func stopCaptureSession()
    func updateVideoOrientation()
    func update(previewLayerFrame: CGRect, roiInPreviewLayer: CGRect)
}

internal class CardScannerViewModel: CardScannerViewModelProtocol {

    // MARK: - Properties

    private let cardImageParser: CardImageParsing
    private var captureSessionManager: CaptureSessionManaging
    private let completion: (Result<CreditCard, CardScannerError>) -> Void

    private var previewFrame: CGRect = .zero
    private var roiInPreviewFrame: CGRect = .zero

    // MARK: - Initializers

    internal init(
        cardImageParser: CardImageParsing,
        captureSessionManager: CaptureSessionManaging,
        completion: @escaping (Result<CreditCard, CardScannerError>) -> Void
    ) {
        self.cardImageParser = cardImageParser
        self.captureSessionManager = captureSessionManager
        self.completion = completion
        self.captureSessionManager.delegate = self
    }

    // MARK: - CardScannerViewModelProtocol

    internal var videoPreviewLayer: CALayer {
        captureSessionManager.videoPreviewLayer
    }

    internal func configureSession() {
        captureSessionManager.configureSession()
    }

    internal func startCaptureSession() {
        captureSessionManager.startCaptureSession()
    }

    internal func stopCaptureSession() {
        captureSessionManager.stopCaptureSession()
    }

    internal func updateVideoOrientation() {
        captureSessionManager.updateVideoOrientation()
    }

    internal func update(previewLayerFrame: CGRect, roiInPreviewLayer: CGRect) {
        self.previewFrame = previewLayerFrame
        self.roiInPreviewFrame = roiInPreviewLayer
    }

    // MARK: - Private

    private func fetchCardData(
        from image: CIImage,
        roiInPreviewFrame: CGRect,
        previewFrame: CGRect
    ) {
        let croppedImage = cropRegionOfInterest(
            from: image,
            roiInPreviewFrame: roiInPreviewFrame,
            previewFrame: previewFrame
        )

        cardImageParser.parse(image: croppedImage) { [weak self] creditCard in
            self?.completion(.success(creditCard))
        }
    }

    private func cropRegionOfInterest(
        from image: CIImage,
        roiInPreviewFrame: CGRect,
        previewFrame: CGRect
    ) -> CIImage {
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

// MARK: - CaptureSessionDelegate

extension CardScannerViewModel: CaptureSessionDelegate {

    internal func didCapture(image: CIImage?) {
        guard let image else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            fetchCardData(
                from: image,
                roiInPreviewFrame: roiInPreviewFrame,
                previewFrame: previewFrame
            )
        }
    }
}
