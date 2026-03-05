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
        let (sut, _) = makeSUT(paymentMethodType: .pix)
        
        // When
        XCTAssertEqual(sut.flowType, .copyCode)
    }
    
    func test_flowType_forPromptPay_returnsSaveCodeAsImage() {
        // Given
        let (sut, _) = makeSUT(paymentMethodType: .promptPay)
        
        // When
        XCTAssertEqual(sut.flowType, .saveCodeAsImage)
    }
    
    // MARK: - qrCodeData
    
    func test_qrCodeData_returnsValidQRCodeData() {
        // Given
        let qrCodeData = "ABC123"
        
        // When
        let (sut, _) = makeSUT(qrCodeData: qrCodeData)
        
        // Then
        XCTAssertEqual(sut.qrCodeData, qrCodeData)
    }
    
    // MARK: - loadLogoImage
    
    func test_loadLogoImage_callsImageLoaderWithURL() {
        // Given
        let imageLoader = ImageLoaderMock()
        let (sut, loader) = makeSUT(imageLoader: imageLoader)
        
        // When
        sut.loadLogoImage { _ in }
        
        // Then
        XCTAssertEqual(loader.loadCallsCount, 1)
    }
    
    // MARK: - performAction (.copyCode)
    
    func test_performAction_copyCode_callOnCopyCode() {
        // Given
        let copyCodeExpectation = expectation(description: "copyCode was not called")
        var receivedCode: String?
        
        let (sut, _) = makeSUT(
            paymentMethodType: .pix,
            onCopyCode: ({ code in
                copyCodeExpectation.fulfill()
                receivedCode = code
            })
        )
        
        // When
        sut.performAction(qrCodeImage: nil, from: UIView())
        
        // Then
        wait(for: [copyCodeExpectation], timeout: 0.1)
        XCTAssertEqual(sut.qrCodeData, receivedCode)
    }
    
    func test_performAction_copyCode_togglesCopyInProgressTemporarily() {
        // Given
        let expectation = self.expectation(description: "copyInProgress reset to false")
        let (sut, _) = makeSUT(
            paymentMethodType: .pix,
            onCopyCode: ({ _ in })
        )
        
        // When
        sut.performAction(qrCodeImage: nil, from: UIView())
        
        // Then
        XCTAssertTrue(sut.copyInProgress.wrappedValue, "copyInProgress should be true immediately")
        
        // After delay of 2 seconds, should become false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            XCTAssertFalse(sut.copyInProgress.wrappedValue, "copyInProgress should reset to false after delay")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.5)
    }
    
    func test_performAction_copyCode_startAnimation() {
        // Given
        let expectedView = UIView()
        let copyCodeExpectation = expectation(description: "copyCode was not called")
        var receivedCode: String?
        
        let (sut, _) = makeSUT(
            paymentMethodType: .pix,
            onCopyCode: ({ code in
                copyCodeExpectation.fulfill()
                receivedCode = code
            })
        )
        
        // When
        sut.performAction(qrCodeImage: nil, from: expectedView)
        
        // Then
        wait(for: [copyCodeExpectation], timeout: 0.1)
        XCTAssertEqual(sut.qrCodeData, receivedCode)
    }
    
    // MARK: - performAction (.saveCodeAsImage)
    
    func test_performAction_saveCodeAsImage_callsOnSaveQRCode() {
        // Given
        let expectedView = UIView()
        let expectedImage = UIImage()
        let onSaveQRCodeExpectation = expectation(description: "onSaveQRCode was not called")
        
        var receivedImage: UIImage?
        var receivedSourceView: UIView?
        
        let (sut, _) = makeSUT(
            paymentMethodType: .promptPay,
            onSaveQRCode: ({ qrCodeImage, sourceView in
                onSaveQRCodeExpectation.fulfill()
                receivedImage = qrCodeImage
                receivedSourceView = sourceView
                
            })
        )
        
        // When
        sut.performAction(qrCodeImage: expectedImage, from: expectedView)
        
        // Then
        wait(for: [onSaveQRCodeExpectation], timeout: 0.1)
        XCTAssertEqual(expectedImage, receivedImage)
        XCTAssertEqual(expectedView, receivedSourceView)
    }
    
    func test_performAction_saveCodeAsImage_noImage_doesNotCallOnSaveQRCode() {
        // Given
        let onSaveQRCodeExpectation = expectation(description: "onSaveQRCode was called")
        onSaveQRCodeExpectation.isInverted = true
        
        let (sut, _) = makeSUT(
            paymentMethodType: .promptPay,
            onSaveQRCode: ({ _, _ in
                onSaveQRCodeExpectation.fulfill()
            })
        )
        
        // When
        sut.performAction(qrCodeImage: nil, from: UIView())
        
        // Then
        wait(for: [onSaveQRCodeExpectation], timeout: 1.0)
    }
    
    // MARK: - Button Titles
    
    func test_actionButtonTitle_and_onCopyButtonTitle_forCopyCode() {
        // Given
        let (sut, _) = makeSUT(paymentMethodType: .pix)
        
        // Then
        XCTAssertEqual(sut.actionButtonTitle, localizedString(.pixCodeCopyLabel, nil))
        XCTAssertEqual(sut.onCopyButtonTitle, localizedString(.pixCodeCopiedLabel, nil))
    }
    
    func test_actionButtonTitle_and_onCopyButtonTitle_forSaveCodeAsImage() {
        // Given
        let (sut, _) = makeSUT(paymentMethodType: .promptPay)
        
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
    ) -> (sut: QRCodeViewModel, imageLoader: ImageLoaderMock) {
        
        let action = QRCodeAction(
            paymentMethodType: paymentMethodType,
            qrCodeData: qrCodeData,
            paymentData: paymentData
        )
        let expiration = AdyenObservable<String?>(nil)
        
        let sut = QRCodeViewModel(
            action: action,
            instructionText: "Test Instruction",
            amount: nil,
            logoUrl: URL(string: "https://www.adyen.com/")!,
            observedProgress: nil,
            expiration: expiration,
            imageLoader: imageLoader,
            localizationParameters: nil,
            onSaveQRCode: onSaveQRCode,
            onCopyCode: onCopyCode
        )
        
        return (sut, imageLoader)
    }
}
