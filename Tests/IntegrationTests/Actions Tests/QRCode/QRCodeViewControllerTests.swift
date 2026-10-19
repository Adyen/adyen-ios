//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@_spi(AdyenInternal) @testable import AdyenUI
import UIKit
import XCTest

final class QRCodeViewControllerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_viewLoad_callsLoadLogoImageOnce() {
        // Given
        let (sut, viewModel) = makeSUT()
        
        // When
        sut.loadViewIfNeeded()
        
        // Then
        XCTAssertTrue(viewModel.loadLogoImageCalled, "Expected loadLogoImage to be called once on viewLoad")
        XCTAssertEqual(viewModel.loadLogoImageCallsCount, 1)
    }
    
    func test_loadLogoImageCompletion_setsLogoImageViewImage() {
        // Given
        let (sut, viewModel) = makeSUT()
        let expectedImage = UIImage(systemName: "star")
        
        // When
        sut.loadViewIfNeeded()
        viewModel.completeLoadLogoImage(with: expectedImage)
        
        // Then
        XCTAssertEqual(sut.logoImageView.image, expectedImage)
    }
    
    func test_instructionLabel_displaysTextFromViewModel() {
        // Given
        let (sut, viewModel) = makeSUT()
        
        // When
        sut.loadViewIfNeeded()
        
        // Then
        XCTAssertEqual(sut.instructionLabel.text, viewModel.instructionText)
        XCTAssertEqual(sut.instructionLabel.accessibilityIdentifier?.contains("instructionLabel"), true)
    }
    
    func test_actionButton_hasCorrectTitleAndIdentifierForCopyCodeFlow() {
        // Given
        let (sut, viewModel) = makeSUT(flowType: .copyCode)
        
        // When
        sut.loadViewIfNeeded()
        
        // Then
        XCTAssertEqual(sut.actionButton.title, viewModel.actionButtonTitle)
        XCTAssertTrue(
            sut.actionButton.accessibilityIdentifier?.contains("copyCodeButton") ?? false,
            "Expected copyCodeButton identifier for .copyCode flow"
        )
    }
    
    func test_actionButton_hasCorrectTitleAndIdentifierForSaveAsImageFlow() {
        // Given
        let (sut, viewModel) = makeSUT(flowType: .saveCodeAsImage)
        
        // When
        sut.loadViewIfNeeded()
        
        // Then
        XCTAssertEqual(sut.actionButton.title, viewModel.actionButtonTitle)
        XCTAssertTrue(
            sut.actionButton.accessibilityIdentifier?.contains("saveAsImageButton") ?? false,
            "Expected saveAsImageButton identifier for .saveCodeAsImage flow"
        )
    }
    
    func test_actionButtonTapped_triggersPerformActionOnViewModel() {
        // Given
        let (sut, viewModel) = makeSUT()
        
        // When
        sut.actionButton.sendActions(for: .touchUpInside)
        
        // Then
        XCTAssertTrue(viewModel.performActionCalled)
        XCTAssertEqual(viewModel.performActionCallsCount, 1)
    }
    
    func test_viewAccessibilityIdentifier_andBackgroundColorConfiguredCorrectly() {
        // Given
        let (sut, _) = makeSUT()
        
        // When
        sut.loadViewIfNeeded()
        
        // Then
        XCTAssertEqual(sut.view.accessibilityIdentifier, "adyen.QRCode")
        XCTAssertEqual(sut.view.backgroundColor, .white)
    }
    
    func test_copyCodeLabel_existsOnlyForCopyCodeFlow() {
        // copyCode flow
        var (sut, _) = makeSUT(flowType: .copyCode)
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(
            sut.view.subviews.contains(where: { $0 is UIScrollView }),
            "Expected scrollView in hierarchy"
        )
        XCTAssertTrue(
            sut.view.findSubview(ofType: CopyLabelView.self) != nil,
            "Expected CopyLabelView for .copyCode flow"
        )
        
        // saveAsImage flow
        (sut, _) = makeSUT(flowType: .saveCodeAsImage)
        sut.loadViewIfNeeded()
        
        XCTAssertNil(
            sut.view.findSubview(ofType: CopyLabelView.self),
            "Expected no CopyLabelView for .saveCodeAsImage flow"
        )
    }
    
    func test_copyAnimation_givenCopyInProgressFalse_changesButtonTitleToOnCopyTitle() {
        // Given
        let (sut, viewModel) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertFalse(viewModel.copyInProgress.wrappedValue)
                
        // When
        viewModel.copyInProgress.wrappedValue = true
        
        // Then
        XCTAssertEqual(sut.actionButton.title, viewModel.onCopyButtonTitle)
    }
    
    func test_copyAnimation_givenCopyInProgressTrue_changesButtonTitleToActionTitle() {
        // Given
        let (sut, viewModel) = makeSUT()
        sut.loadViewIfNeeded()
        viewModel.copyInProgress.wrappedValue = true
        XCTAssertTrue(viewModel.copyInProgress.wrappedValue)
                
        // When
        viewModel.copyInProgress.wrappedValue = false
        
        // Then
        XCTAssertEqual(sut.actionButton.title, viewModel.actionButtonTitle)
    }
    
    func test_preferredContentSize_returnsGreatestFiniteMagnitude() {
        // Given
        let (sut, _) = makeSUT()
        
        // When
        let size = sut.preferredContentSize
        
        // Then
        XCTAssertEqual(size.width, .greatestFiniteMagnitude)
        XCTAssertEqual(size.height, .greatestFiniteMagnitude)
    }
    
    // MARK: - Private
    
    private func makeSUT(flowType: QRCodeFlowType = .copyCode) -> (sut: QRCodeViewController, viewModel: QRCodeViewModelMock) {
        let viewModel = QRCodeViewModelMock()
        viewModel.flowType = flowType
        viewModel.instructionText = "Scan this QR code"
        viewModel.actionButtonTitle = "Copy Code"
        viewModel.onCopyButtonTitle = "Copied!"
        viewModel.qrCodeData = "123456"
        
        let style = QRCodeViewStyle(
            copyCodeButton: .init(title: .init(font: .systemFont(ofSize: 16), color: .black)),
            saveAsImageButton: .init(title: .init(font: .systemFont(ofSize: 16), color: .black)),
            instructionLabel: .init(font: .systemFont(ofSize: 16), color: .black),
            amountToPayLabel: .init(font: .systemFont(ofSize: 16), color: .black),
            progressView: .init(progressTintColor: .blue, trackTintColor: .gray),
            expirationLabel: .init(font: .systemFont(ofSize: 16), color: .black),
            logoCornerRounding: .fixed(8),
            backgroundColor: .white
        )
        
        let sut = QRCodeViewController(viewModel: viewModel, style: style)
        return (sut, viewModel)
    }
}

// MARK: - findSubview

private extension UIView {
    func findSubview<T: UIView>(ofType type: T.Type) -> T? {
        if let view = self as? T { return view }
        for subview in subviews {
            if let found = subview.findSubview(ofType: type) {
                return found
            }
        }
        return nil
    }
}
