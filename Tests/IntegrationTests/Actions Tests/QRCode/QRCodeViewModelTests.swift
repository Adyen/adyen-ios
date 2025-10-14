//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenActions
import UIKit
import XCTest
@_spi(AdyenInternal) @testable import Adyen

class QRCodeViewModelTests: XCTestCase {
    
    // MARK: - Flow Type
    
    func test_flowType_forPix_returnsCopyCode() {
        // Given
        let (sut, _, _) = makeSUT(paymentMethodType: .pix)
        
        // When
        XCTAssertEqual(sut.flowType, .copyCode)
    }
    
    func test_flowType_forPromptPay_returnsSaveCodeAsImage() {
        // Given
        let (sut, _, _) = makeSUT(paymentMethodType: .promptPay)
        
        // When
        XCTAssertEqual(sut.flowType, .saveCodeAsImage)
    }
    
    // MARK: - qrCodeData
    
    func test_qrCodeData_returnsValidQRCodeData() {
        // Given
        let qrCodeData = "ABC123"
        
        // When
        let (sut, _, _) = makeSUT(qrCodeData: qrCodeData)
        
        // Then
        XCTAssertEqual(sut.qrCodeData, qrCodeData)
    }
    
    // MARK: - loadLogoImage
    
    func test_loadLogoImage_callsImageLoaderWithURL() {
        // Given
        let imageLoader = ImageLoaderMock()
        let (sut, _, loader) = makeSUT(imageLoader: imageLoader)
        
        // When
        sut.loadLogoImage { _ in }
        
        // Then
        XCTAssertEqual(loader.loadCallsCount, 1)
    }
    
    // MARK: - performAction (.copyCode)
    
    func test_performAction_copyCode_callsStartCopyAnimationAndOnCopyCode() throws {
        // Given
        let copyCodeExpectation = expectation(description: "copyCode was not called")
        var receivedCode: String?
        
        let (sut, view, _) = makeSUT(
            paymentMethodType: .pix,
            onCopyCode: ({ code in
                copyCodeExpectation.fulfill()
                receivedCode = code
            })
        )
        
        // When
        sut.performAction(qrCodeImage: nil)
        
        // Then
        wait(for: [copyCodeExpectation], timeout: 0.1)
        XCTAssertEqual(view.startCopyAnimationCallsCount, 1)
        XCTAssertEqual(sut.qrCodeData, receivedCode)
    }
    
    // MARK: - performAction (.saveCodeAsImage)
    
    func test_performAction_saveCodeAsImage_callsOnSaveQRCode() {
        // Given
        let expectedImage = UIImage()
        let onSaveQRCodeExpectation = expectation(description: "onSaveQRCode was not called")
        
        var receivedImage: UIImage?
        var receivedSourceView: UIView?
        
        let (sut, view, _) = makeSUT(
            paymentMethodType: .promptPay,
            onSaveQRCode: ({ qrCodeImage, sourceView in
                onSaveQRCodeExpectation.fulfill()
                receivedImage = qrCodeImage
                receivedSourceView = sourceView
                
            })
        )
        
        // When
        sut.performAction(qrCodeImage: expectedImage)
        
        // Then
        wait(for: [onSaveQRCodeExpectation], timeout: 0.1)
        XCTAssertEqual(expectedImage, receivedImage)
        XCTAssertEqual(view.rootView, receivedSourceView)
    }
    
    func test_performAction_saveCodeAsImage_noImage_doesNotCallOnSaveQRCode() {
        // Given
        let onSaveQRCodeExpectation = expectation(description: "onSaveQRCode was called")
        onSaveQRCodeExpectation.isInverted = true
        
        let (sut, _, _) = makeSUT(
            paymentMethodType: .promptPay,
            onSaveQRCode: ({ _, _ in
                onSaveQRCodeExpectation.fulfill()
            })
        )
        
        // When
        sut.performAction(qrCodeImage: nil)
        
        // Then
        wait(for: [onSaveQRCodeExpectation], timeout: 1.0)
    }
    
    // MARK: - Button Titles
    
    func test_actionButtonTitle_and_onCopyButtonTitle_forCopyCode() {
        // Given
        let (sut, _, _) = makeSUT(paymentMethodType: .pix)
        
        // Then
        XCTAssertEqual(sut.actionButtonTitle, localizedString(.pixCodeCopyLabel, nil))
        XCTAssertEqual(sut.onCopyButtonTitle, localizedString(.pixCodeCopiedLabel, nil))
    }
    
    func test_actionButtonTitle_and_onCopyButtonTitle_forSaveCodeAsImage() {
        // Given
        let (sut, _, _) = makeSUT(paymentMethodType: .promptPay)
        
        // Then
        XCTAssertEqual(sut.actionButtonTitle, localizedString(.voucherSaveImage, nil))
        XCTAssertEqual(sut.onCopyButtonTitle, localizedString(.voucherSaveImage, nil))
    }
    
    // MARK: - Private
    
    private func makeSUT(
        paymentMethodType: QRCodePaymentMethod = .pix,
        qrCodeData: String = "123",
        paymentData: String = "payment-data",
        imageLoader: ImageLoaderMock = ImageLoaderMock(),
        onSaveQRCode: @escaping (_ image: UIImage?, _ sourceView: UIView) -> Void = { _, _ in },
        onCopyCode: @escaping (_ code: String) -> Void = { _ in }
    ) -> (sut: QRCodeViewModel, view: QRCodeViewMock, imageLoader: ImageLoaderMock) {
        
        let action = QRCodeAction(
            paymentMethodType: paymentMethodType,
            qrCodeData: qrCodeData,
            paymentData: paymentData
        )
        let expiration = AdyenObservable<String?>(nil)
        let view = QRCodeViewMock()
        
        let sut = QRCodeViewModel(
            action: action,
            instructionText: "Test Instruction",
            payment: nil,
            logoUrl: URL(string: "https://www.adyen.com/")!,
            observedProgress: nil,
            expiration: expiration,
            imageLoader: imageLoader,
            localizationParameters: nil,
            onSaveQRCode: onSaveQRCode,
            onCopyCode: onCopyCode
        )
        sut.view = view
        
        return (sut, view, imageLoader)
    }
}
