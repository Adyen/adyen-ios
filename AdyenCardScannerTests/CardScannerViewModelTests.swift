//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import AVFoundation
import XCTest

final class CardScannerViewModelTests: XCTestCase {

    enum Constants {
        static let mockCardImage = "adyen-card-iphone-capture"
    }

    var cardImageParser: CardImageParsingMock!
    var captureSessionManager: CaptureSessionManagingMock!
    var appOpener: AppOpenerMock!
    var localizationBundle: Bundle!
    var view: CardScannerPresentingMock!
    var sut: CardScannerViewModel!

    override func tearDownWithError() throws {
        cardImageParser = nil
        captureSessionManager = nil
        localizationBundle = nil
        view = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testVideoPreviewLayer() {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        let expectedVideoPreviewLayer = AVCaptureVideoPreviewLayer()
        captureSessionManager.videoPreviewLayer = expectedVideoPreviewLayer
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        // When
        let receivedVideoPreviewLayer = sut.videoPreviewLayer

        // Then
        XCTAssertTrue(expectedVideoPreviewLayer === receivedVideoPreviewLayer)
    }

    func testRequestCaptureAuthorizationGivenAuthorizedShouldCallCaptureSessionManagerConfigureSession() {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        captureSessionManager.requestCaptureAuthorizationReturnValue = .authorized

        let configureSessionExpectation = expectation(description: "Capture session should be configured.")
        captureSessionManager.configureSessionClosure = {
            // Then
            configureSessionExpectation.fulfill()
            XCTAssertEqual(self.captureSessionManager.configureSessionCallsCount, 1)
        }

        // When
        sut.requestCaptureAuthorization()

        wait(for: [configureSessionExpectation], timeout: 1.0)
    }

    func testRequestCaptureAuthorizationGivenRejectedShouldCallViewDismiss() {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        captureSessionManager.requestCaptureAuthorizationReturnValue = .rejected

        let dismissExpectation = expectation(description: "View should be dismissed.")
        view.dismissClosure = {
            // Then
            dismissExpectation.fulfill()
            XCTAssertEqual(self.view.dismissCallsCount, 1)
        }

        // When
        sut.requestCaptureAuthorization()

        wait(for: [dismissExpectation], timeout: 1.0)

    }

    func testRequestCaptureAuthorizationGivenDeniedShouldCallViewDismiss() {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        captureSessionManager.requestCaptureAuthorizationReturnValue = .denied

        let presentAccessDeniedAlertExpectation = expectation(description: "View should be dismissed.")
        view.presentCameraAccessDeniedAlertClosure = {
            // Then
            presentAccessDeniedAlertExpectation.fulfill()
            XCTAssertEqual(self.view.presentCameraAccessDeniedAlertCallsCount, 1)
        }

        // When
        sut.requestCaptureAuthorization()

        wait(for: [presentAccessDeniedAlertExpectation], timeout: 1.0)
    }

    func testStartCaptureSessionShouldCallCaptureSessionManagerStartCaptureSession() {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        // When
        sut.startCaptureSession()

        // Then
        XCTAssertEqual(captureSessionManager.startCaptureSessionCallsCount, 1)
    }

    func testStartCaptureSessionShouldCallCaptureSessionManagerStopCaptureSession() {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        // When
        sut.stopCaptureSession()

        // Then
        XCTAssertEqual(captureSessionManager.stopCaptureSessionCallsCount, 1)
    }

    func testStartCaptureSessionShouldCallCaptureSessionManagerUpdateVideoOrientation() {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        // When
        sut.updateVideoOrientation()

        // Then
        XCTAssertEqual(captureSessionManager.updateVideoOrientationCallsCount, 1)
    }

    func testDidCaptureWithImageShouldParseCardImage() throws {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        let image = UIImage(
            named: Constants.mockCardImage,
            in: Bundle(for: type(of: self)),
            compatibleWith: nil
        )
        let cgImage = try XCTUnwrap(image?.cgImage)
        let ciImage = CIImage(cgImage: cgImage)

        let expectation = expectation(description: "Image should be parsed")

        cardImageParser.parseClosure = { _, _ in
            expectation.fulfill()
        }

        // When
        sut.didCapture(image: ciImage)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(cardImageParser.parseCallsCount, 1)
    }

    func testDidCaptureWithNilImageShouldNotParseCardImage() {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        // When
        sut.didCapture(image: nil)

        // Then
        XCTAssertEqual(cardImageParser.parseCallsCount, 0)
    }

    func testDidCaptureWithImageShouldCropImageToRegionOfInterest() throws {
        // Given
        let expectedCroppedImageSize = CGSize(width: 883.0, height: 1042.0)

        let previewLayerFrame = UIScreen.main.bounds

        let roiInPreviewLayer = CGRect(
            x: 20,
            y: 200,
            width: previewLayerFrame.width - 32,
            height: previewLayerFrame.height * 0.5
        )

        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        let image = UIImage(
            named: Constants.mockCardImage,
            in: Bundle(for: type(of: self)),
            compatibleWith: nil
        )
        let cgImage = try XCTUnwrap(image?.cgImage)
        let originalImage = CIImage(cgImage: cgImage)

        let expectation = expectation(description: "Image should be parsed")

        cardImageParser.parseClosure = { _, _ in
            expectation.fulfill()
        }

        let cardScannerViewController = CardScannerViewController(viewModel: sut)
        cardScannerViewController.viewDidLoad()

        // When
        sut.update(previewLayerFrame: previewLayerFrame, roiInPreviewLayer: roiInPreviewLayer)
        sut.didCapture(image: originalImage)

        // Then
        waitForExpectations(timeout: 1.0)

        let croppedImage = try XCTUnwrap(cardImageParser.parseReceivedImage)

        XCTAssertNotEqual(croppedImage.extent.size, originalImage.extent.size)
        XCTAssertEqual(expectedCroppedImageSize, croppedImage.extent.size)
    }

    func testOpenSettingsApp() {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        let openSettingsAppExpectation = expectation(description: "Settings app should be opened.")
        appOpener.openSettingsAppClosure = {
            openSettingsAppExpectation.fulfill()
            XCTAssertEqual(self.appOpener.openSettingsAppCallsCount, 1)
        }

        // When
        sut.openSettingsApp()

        wait(for: [openSettingsAppExpectation], timeout: 1.0)
    }

    // MARK: - Localization

    func testCameraAlertTitle() {
        // Given
        let expectedCameraAlertTitle = "adyen.card.scanner.camera.access.denied.alert.title"

        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        // When
        let cameraAlertTitle = sut.cameraAlertTitle

        // Then
        XCTAssertEqual(
            expectedCameraAlertTitle,
            cameraAlertTitle
        )
    }

    func testCameraAlertMessage() {
        // Given
        let expectedCameraAlertMessage = "adyen.card.scanner.camera.access.denied.alert.message"

        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        // When
        let cameraAlertMessage = sut.cameraAlertMessage

        // Then
        XCTAssertEqual(
            expectedCameraAlertMessage,
            cameraAlertMessage
        )
    }

    func testCameraAlertSettingButtonTitle() {
        // Given
        let expectedCameraAlertSettingButtonTitle = "adyen.card.scanner.camera.access.denied.alert.settingsButton.title"

        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        // When
        let cameraAlertSettingButtonTitle = sut.cameraAlertSettingButtonTitle

        // Then
        XCTAssertEqual(
            expectedCameraAlertSettingButtonTitle,
            cameraAlertSettingButtonTitle
        )
    }

    func testCameraAlertCancelButtonTitle() {
        // Given
        let expectedCameraAlertSettingButtonTitle = "adyen.cancelButton"

        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        appOpener = AppOpenerMock()
        localizationBundle = Bundle.main
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            appOpener: appOpener,
            localizationBundle: localizationBundle
        ) { _ in }
        view = CardScannerPresentingMock()
        sut.view = view

        // When
        let cameraAlertCancelButtonTitle = sut.cameraAlertCancelButtonTitle

        // Then
        XCTAssertEqual(
            expectedCameraAlertSettingButtonTitle,
            cameraAlertCancelButtonTitle
        )
    }
}
