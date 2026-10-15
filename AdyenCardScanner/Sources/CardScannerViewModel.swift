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
    func requestCaptureAuthorization()
    func startCaptureSession()
    func stopCaptureSession()
    func updateVideoOrientation()
    func update(previewLayerFrame: CGRect, roiInPreviewLayer: CGRect)
    func openSettingsApp()

    // Localization
    var cameraAlertTitle: String { get }
    var cameraAlertMessage: String { get }
    var cameraAlertSettingButtonTitle: String { get }
    var cameraAlertCancelButtonTitle: String { get }
}

internal class CardScannerViewModel: CardScannerViewModelProtocol {

    // MARK: - Properties

    internal weak var view: CardScannerPresenting?
    private let cardImageParser: CardImageParsing
    private var captureSessionManager: CaptureSessionManaging
    private let appOpener: AppOpener
    private let localizationBundle: Bundle
    private let completion: (Result<CardScanDetails, CardScannerError>) -> Void

    private var previewFrame: CGRect = .zero
    private var roiInPreviewFrame: CGRect = .zero

    // MARK: - Initializers

    internal init(
        cardImageParser: CardImageParsing,
        captureSessionManager: CaptureSessionManaging,
        appOpener: AppOpener,
        localizationBundle: Bundle,
        completion: @escaping (Result<CardScanDetails, CardScannerError>) -> Void
    ) {
        self.cardImageParser = cardImageParser
        self.captureSessionManager = captureSessionManager
        self.appOpener = appOpener
        self.localizationBundle = localizationBundle
        self.completion = completion
        self.captureSessionManager.delegate = self
    }

    // MARK: - CardScannerViewModelProtocol

    internal var videoPreviewLayer: CALayer {
        captureSessionManager.videoPreviewLayer
    }

    internal func requestCaptureAuthorization() {
        Task { @MainActor in
            let authorizationStatus = await captureSessionManager.requestCaptureAuthorization()

            switch authorizationStatus {
            case .authorized:
                configureSession()
            case .rejected:
                view?.dismiss()
            case .denied:
                view?.presentCameraAccessDeniedAlert()
            }
        }
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

    internal func openSettingsApp() {
        Task {
            await appOpener.openSettingsApp()
        }
    }

    // MARK: - Private

    private func configureSession() {
        captureSessionManager.configureSession()
    }

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
            let cardDetails = (
                number: creditCard.number,
                expirationDate: creditCard.expirationDate
            )
            self?.completion(.success(cardDetails))
        }
    }

    internal func cropRegionOfInterest(
        from image: CIImage,
        roiInPreviewFrame: CGRect,
        previewFrame: CGRect
    ) -> CIImage {
        guard previewFrame.width > 0, previewFrame.height > 0, !roiInPreviewFrame.isEmpty else { return image }

        // The preview is aspect-fill: a single scale maps points to pixels and the overflow is cropped evenly on both sides.
        let imageWidth = image.extent.width
        let imageHeight = image.extent.height
        let scale = min(imageWidth / previewFrame.width, imageHeight / previewFrame.height)
        let xOffset = (imageWidth - previewFrame.width * scale) * 0.5
        let yOffset = (imageHeight - previewFrame.height * scale) * 0.5

        // The ROI origin is top-left whereas the CIImage origin is bottom-left.
        let roiHeight = roiInPreviewFrame.height * scale
        let adjustedROI = CGRect(
            x: image.extent.minX + xOffset + roiInPreviewFrame.origin.x * scale,
            y: image.extent.minY + imageHeight - yOffset - roiInPreviewFrame.origin.y * scale - roiHeight,
            width: roiInPreviewFrame.width * scale,
            height: roiHeight
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

// MARK: - Localization

extension CardScannerViewModel {

    private enum LocalizationKey: String {
        case cameraAlertTitle = "adyen.card.scanner.camera.access.denied.alert.title"
        case cameraAlertMessage = "adyen.card.scanner.camera.access.denied.alert.message"
        case cameraAlertSettingButtonTitle = "adyen.card.scanner.camera.access.denied.alert.settingsButton.title"
        case cameraAlertCancelButtonTitle = "adyen.cancelButton"
    }

    internal var cameraAlertTitle: String {
        localizedString(forKey: .cameraAlertTitle)
    }

    internal var cameraAlertMessage: String {
        localizedString(forKey: .cameraAlertMessage)
    }

    internal var cameraAlertSettingButtonTitle: String {
        localizedString(forKey: .cameraAlertSettingButtonTitle)
    }

    internal var cameraAlertCancelButtonTitle: String {
        localizedString(forKey: .cameraAlertCancelButtonTitle)
    }

    // MARK: - Private

    private func localizedString(
        forKey key: LocalizationKey,
        comment: String = ""
    ) -> String {
        NSLocalizedString(
            key.rawValue,
            bundle: localizationBundle,
            comment: ""
        )
    }
}
