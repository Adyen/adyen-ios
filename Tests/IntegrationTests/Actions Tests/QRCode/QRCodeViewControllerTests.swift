//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenActions
import XCTest
@_spi(AdyenInternal) @testable import Adyen
import UIKit

final class QRCodeViewControllerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_viewDidLoad_callsLoadLogoImageOnce() {
        // Given
        let (sut, viewModel) = makeSUT()
        
        // When
        sut.loadViewIfNeeded()
        
        // Then
        XCTAssertTrue(viewModel.loadLogoImageCalled, "Expected loadLogoImage to be called once on viewDidLoad")
        XCTAssertEqual(viewModel.loadLogoImageCallsCount, 1)
    }
    
    func test_loadLogoImageCompletion_setsLogoImageViewImage() {
        // Given
        let (sut, viewModel) = makeSUT()
        let expectedImage = UIImage(systemName: "star")
        
        // When
        sut.viewDidLoad()
        viewModel.completeLoadLogoImage(with: expectedImage)
        
        // Then
        XCTAssertEqual(sut.logoImageView.image, expectedImage)
    }
    
    func test_instructionLabel_displaysTextFromViewModel() {
        // Given
        let (sut, viewModel) = makeSUT()
        
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertEqual(sut.instructionLabel.text, viewModel.instructionText)
        XCTAssertEqual(sut.instructionLabel.accessibilityIdentifier?.contains("instructionLabel"), true)
    }
    
    func test_actionButton_hasCorrectTitleAndIdentifierForCopyCodeFlow() {
        // Given
        let (sut, viewModel) = makeSUT(flowType: .copyCode)
        
        // When
        sut.viewDidLoad()
        
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
        sut.viewDidLoad()
        
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
        sut.viewDidLoad()
        
        // Then
        XCTAssertEqual(sut.view.accessibilityIdentifier, "adyen.QRCode")
        XCTAssertEqual(sut.view.backgroundColor, .white)
    }
    
    func test_copyCodeLabel_existsOnlyForCopyCodeFlow() {
        // copyCode flow
        var (sut, _) = makeSUT(flowType: .copyCode)
        sut.viewDidLoad()
        
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
        sut.viewDidLoad()
        
        XCTAssertNil(
            sut.view.findSubview(ofType: CopyLabelView.self),
            "Expected no CopyLabelView for .saveCodeAsImage flow"
        )
    }
    
    func test_startCopyAnimation_changesButtonTitleTemporarily() {
        // Given
        let (sut, viewModel) = makeSUT()
        sut.viewDidLoad()
        
        let initialTitle = sut.actionButton.title
        
        // When
        sut.startCopyAnimation()
        
        // Then
        XCTAssertEqual(sut.actionButton.title, viewModel.onCopyButtonTitle)
        
        // Simulate 2-second delay completion
        let animationExpectation = expectation(description: "Wait for title reset")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            XCTAssertEqual(sut.actionButton.title, initialTitle)
            animationExpectation.fulfill()
        }
        wait(for: [animationExpectation], timeout: 2.5)
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
        sut.loadViewIfNeeded()
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
