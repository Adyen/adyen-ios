//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
import AVFoundation
@testable import AdyenCardScanner

final class CardScannerViewModelTests: XCTestCase {

    enum Constants {
        static let mockCardImage = "adyen-card-iphone-capture"
    }

    var cardImageParser: CardImageParsingMock!
    var captureSessionManager: CaptureSessionManagingMock!
    var sut: CardScannerViewModel!

    override func tearDownWithError() throws {
        cardImageParser = nil
        captureSessionManager = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testVideoPreviewLayer() throws {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()

        let expectedVideoPreviewLayer = AVCaptureVideoPreviewLayer()
        captureSessionManager.videoPreviewLayer = expectedVideoPreviewLayer
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager
        ) { _ in }

        // When
        let receivedVideoPreviewLayer = sut.videoPreviewLayer

        // Then
        XCTAssertTrue(expectedVideoPreviewLayer === receivedVideoPreviewLayer)
    }

    func testConfigureSessionShouldCallCaptureSessionManagerConfigureSession() throws {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager
        ) { _ in }

        // When
        sut.configureSession()

        // Then
        XCTAssertEqual(captureSessionManager.configureSessionCallsCount, 1)
    }

    func testStartCaptureSessionShouldCallCaptureSessionManagerStartCaptureSession() throws {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager
        ) { _ in }

        // When
        sut.startCaptureSession()

        // Then
        XCTAssertEqual(captureSessionManager.startCaptureSessionCallsCount, 1)
    }

    func testStartCaptureSessionShouldCallCaptureSessionManagerStopCaptureSession() throws {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager
        ) { _ in }

        // When
        sut.stopCaptureSession()

        // Then
        XCTAssertEqual(captureSessionManager.stopCaptureSessionCallsCount, 1)
    }

    func testStartCaptureSessionShouldCallCaptureSessionManagerUpdateVideoOrientation() throws {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager
        ) { _ in }

        // When
        sut.updateVideoOrientation()

        // Then
        XCTAssertEqual(captureSessionManager.updateVideoOrientationCallsCount, 1)
    }

    func testDidCaptureWithImageShouldParseCardImage() throws {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager
        ) { _ in }

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

    func testDidCaptureWithNilImageShouldNotParseCardImage() throws {
        // Given
        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager
        ) { _ in }

        // When
        sut.didCapture(image: nil)

        // Then
        XCTAssertEqual(cardImageParser.parseCallsCount, 0)
    }

    func testDidCaptureWithImageShouldCropImageToRegionOfInterest() throws {
        // Given
        let expectedCroppedImageSize = CGSize(width: 885.0, height: 1044.0)

        let previewLayerFrame = UIScreen.main.bounds

        let roiInPreviewLayer = CGRect(
            x: 20,
            y: 200,
            width: previewLayerFrame.width - 32,
            height: previewLayerFrame.height * 0.5
        )

        cardImageParser = CardImageParsingMock()
        captureSessionManager = CaptureSessionManagingMock()
        sut = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager
        ) { _ in }

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
}
