//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import XCTest

final class CardScannerViewControllerTests: XCTestCase {

    var viewModel: CardScannerViewModelMock!
    var sut: CardScannerViewController!

    override func tearDownWithError() throws {
        viewModel = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testViewDidLoadShouldCallViewModelConfigureSession() throws {
        // Given
        viewModel = CardScannerViewModelMock()
        sut = CardScannerViewController(viewModel: viewModel)

        // When
        sut.loadViewIfNeeded()

        // Then
        XCTAssertEqual(viewModel.configureSessionCallsCount, 1)
    }

    func testViewWillAppearShouldStartCaptureSession() throws {
        // Given
        viewModel = CardScannerViewModelMock()
        sut = CardScannerViewController(viewModel: viewModel)

        // When
        sut.viewWillAppear(true)

        // Then
        XCTAssertEqual(viewModel.startCaptureSessionCallsCount, 1)
    }

    func testViewWillDisappearShouldStopCaptureSession() throws {
        // Given
        viewModel = CardScannerViewModelMock()
        sut = CardScannerViewController(viewModel: viewModel)

        // When
        sut.viewWillDisappear(true)

        // Then
        XCTAssertEqual(viewModel.stopCaptureSessionCallsCount, 1)
    }

    func testViewDidLayoutSubviewsShouldUpdateVideoOrientation() throws {
        // Given
        viewModel = CardScannerViewModelMock()
        sut = CardScannerViewController(viewModel: viewModel)

        // When
        sut.viewDidLayoutSubviews()

        // Then
        XCTAssertEqual(viewModel.updateVideoOrientationCallsCount, 1)
    }

    func testVideoPreviewLayerIsSetOnInit() throws {
        // Given
        let expectedVideoPreviewLayer = CALayer()
        viewModel = CardScannerViewModelMock()
        viewModel.videoPreviewLayer = expectedVideoPreviewLayer
        sut = CardScannerViewController(viewModel: viewModel)

        // When
        sut.loadViewIfNeeded()

        // Then
        let layer = try XCTUnwrap(sut.view.layer.sublayers?.first)
        XCTAssertTrue(layer === expectedVideoPreviewLayer)
    }
}
