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
    
    var viewModel: QRCodeViewModelMock!
    var sut: QRCodeViewController!
    
    override func setUp() {
        super.setUp()
        viewModel = QRCodeViewModelMock()
        sut = QRCodeViewController(viewModel: viewModel, style: qrCodeViewStyleMock)
        _ = sut.view // Force view to load
    }
    
    override func tearDown() {
        sut = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - View Lifecycle
    
    func test_viewDidLoad_loadsLogoImage() {
        XCTAssertTrue(viewModel.loadLogoImageCalled, "viewDidLoad should trigger loadLogoImage on the view model")
    }
    
    func test_viewHierarchy_containsExpectedSubviews() {
        XCTAssertTrue(sut.view.subviews.contains(where: { $0 is UIScrollView }))
        XCTAssertNotNil(sut.logoImageView)
        XCTAssertNotNil(sut.instructionLabel)
        XCTAssertNotNil(sut.qrCodeView)
        XCTAssertNotNil(sut.actionButton)
    }
    
    func test_instructionLabel_displaysViewModelText() {
        XCTAssertEqual(sut.instructionLabel.text, viewModel.instructionText)
    }
    
    func test_actionButton_displaysCorrectTitle() {
        XCTAssertEqual(sut.actionButton.title, viewModel.actionButtonTitle)
    }
    
    // MARK: - Actions
    
    func test_copyCodeAction_invokesViewModelCopy() {
        sut.copyCode()
        XCTAssertTrue(viewModel.copyCodeCalled, "copyCode action should call viewModel.copyCode")
    }
    
    func test_saveQRCodeImage_invokesViewModelSave() {
        sut.saveQRCodeImage()
        XCTAssertNotNil(viewModel.saveQRCodeCalled, "saveQRCodeImage should call viewModel.saveQRCode")
        XCTAssertEqual(viewModel.saveQRCodeCalled?.sourceView, sut.view)
    }
    
    func test_preferredContentSize_getter_returnsMaximumSize() {
        let size = sut.preferredContentSize
        XCTAssertEqual(size.width, CGFloat.greatestFiniteMagnitude)
        XCTAssertEqual(size.height, CGFloat.greatestFiniteMagnitude)
    }
    
    // MARK: - Flow Types
    
    func test_copyFlowType_addsCopyLabelView() {
        viewModel.flowType = .copyCode
        sut = QRCodeViewController(viewModel: viewModel, style: qrCodeViewStyleMock)
        _ = sut.view
        XCTAssertNotNil(sut.copyCodeLabel)
    }
    
    func test_saveAsImageFlowType_doesNotAddCopyLabelView() {
        viewModel.flowType = .saveAsImage
        sut = QRCodeViewController(viewModel: viewModel, style: qrCodeViewStyleMock)
        _ = sut.view
        XCTAssertNil(sut.copyCodeLabel)
    }
    
    // MARK: - Private
    
    private let qrCodeViewStyleMock = QRCodeViewStyle(
        copyCodeButton: .init(title: .init(font: .systemFont(ofSize: 16), color: .black)),
        saveAsImageButton: .init(title: .init(font: .systemFont(ofSize: 16), color: .black)),
        instructionLabel: .init(font: .systemFont(ofSize: 16), color: .black),
        amountToPayLabel: .init(font: .systemFont(ofSize: 16), color: .black),
        progressView: .init(progressTintColor: .blue, trackTintColor: .gray),
        expirationLabel: .init(font: .systemFont(ofSize: 16), color: .black),
        logoCornerRounding: .fixed(8),
        backgroundColor: .white
    )
}
