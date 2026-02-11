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

    func testViewDidLoadShouldCallViewModelRequestCaptureAuthorization() {
        // Given
        viewModel = CardScannerViewModelMock()
        sut = CardScannerViewController(viewModel: viewModel)

        let expectation = expectation(description: "Request capture authorization should be called.")

        viewModel.requestCaptureAuthorizationClosure = {
            // Then
            expectation.fulfill()
            XCTAssertEqual(self.viewModel.requestCaptureAuthorizationCallsCount, 1)
        }

        // When
        sut.loadViewIfNeeded()

        wait(for: [expectation], timeout: 0.1)
    }

    func testViewWillAppearShouldStartCaptureSession() {
        // Given
        viewModel = CardScannerViewModelMock()
        sut = CardScannerViewController(viewModel: viewModel)

        // When
        sut.viewWillAppear(true)

        // Then
        XCTAssertEqual(viewModel.startCaptureSessionCallsCount, 1)
    }

    func testViewWillDisappearShouldStopCaptureSession() {
        // Given
        viewModel = CardScannerViewModelMock()
        sut = CardScannerViewController(viewModel: viewModel)

        // When
        sut.viewWillDisappear(true)

        // Then
        XCTAssertEqual(viewModel.stopCaptureSessionCallsCount, 1)
    }

    func testViewDidLayoutSubviewsShouldUpdateVideoOrientation() {
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

    func testPresentCameraAccessDeniedAlert() throws {
        // Given
        viewModel = CardScannerViewModelMock()
        sut = CardScannerViewController(viewModel: viewModel)

        let testWindow = UIWindow(frame: UIScreen.main.bounds)
        testWindow.rootViewController = sut
        testWindow.makeKeyAndVisible()
        _ = sut.view

        // When
        sut.presentCameraAccessDeniedAlert()

        // Then
        let presentedAlert = try XCTUnwrap(sut.presentedViewController as? UIAlertController)
        XCTAssertEqual(presentedAlert.actions.count, 2, "Alert should have two actions.")
    }
}
