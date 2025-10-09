//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenActions
import XCTest

final class QRCodeViewModelTests: XCTestCase {
    
    var sut: QRCodeViewModel!
    var imageLoaderMock: ImageLoaderMock!
    var saveCalled = false
    var copyCalled = false
    
    override func setUp() {
        super.setUp()
        imageLoaderMock = ImageLoaderMock()
        saveCalled = false
        copyCalled = false
        
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
        let action = QRCodeAction(paymentMethodType: .pix, qrCodeData: "123456", paymentData: "paymentData")
        sut = QRCodeViewModel(
            action: action,
            instructionText: "Scan QR",
            payment: nil,
            logoUrl: URL(string: "https://example.com/logo.png")!,
            observedProgress: nil,
            expiration: AdyenObservable(nil),
            style: style,
            imageLoader: imageLoaderMock,
            localizationParameters: nil,
            onSaveQRCode: { _, _ in self.saveCalled = true },
            onCopyCode: { _ in self.copyCalled = true }
        )
    }
    
    override func tearDown() {
        imageLoaderMock = nil
        sut = nil
        super.tearDown()
    }
    
    func test_loadLogoImage() {
        let imageLoadExpectation = expectation(description: "Image was loaded")
        
        sut.loadLogoImage { receivedImage in
            imageLoadExpectation.fulfill()
        }
        
        XCTAssertEqual(imageLoaderMock.loadCallsCount, 1)
        wait(for: [imageLoadExpectation], timeout: 1)
    }
    
    func test_qrCodeData_returnsActionData() {
        XCTAssertEqual(sut.qrCodeData, "123456")
    }
    
    func test_copyCode_callsOnCopyCodeClosure() {
        sut.copyCode()
        XCTAssertTrue(copyCalled)
    }
    
    func test_saveQRCode_callsOnSaveQRCodeClosure() {
        sut.saveQRCode(image: UIImage(), sourceView: UIView())
        XCTAssertTrue(saveCalled)
    }
    
    func test_actionButtonTitle_and_onCopyButtonTitle_matchFlowType() {
        XCTAssertEqual(sut.actionButtonTitle, "Copy PIX code")
        XCTAssertEqual(sut.onCopyButtonTitle, "PIX code copied")
    }
}
