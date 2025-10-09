//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenActions
import XCTest

// MARK: - Mocks

final class QRCodeViewModelMock: QRCodeViewModelProtocol {
    
    // MARK: - Properties
    
    var flowType: QRCodeFlowType
    var instructionText: String
    var amountText: String?
    var actionButtonTitle: String
    var onCopyButtonTitle: String
    var qrCodeData: String
    var style: QRCodeViewStyle
    var expiration: AdyenObservable<String?> = AdyenObservable(nil)
    var observedProgress: Progress?
    
    // MARK: - Initializers

    init(
        flowType: QRCodeFlowType = .copyCode,
        instructionText: String = "Scan QR code",
        actionButtonTitle: String = "Copy",
        onCopyButtonTitle: String = "Copied",
        qrCodeData: String = "123456"
    ) {
        self.flowType = flowType
        self.instructionText = instructionText
        self.actionButtonTitle = actionButtonTitle
        self.onCopyButtonTitle = onCopyButtonTitle
        self.qrCodeData = qrCodeData
        self.style = .init(
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
    
    var loadLogoImageCalled = false
    func loadLogoImage(completion: @escaping (UIImage?) -> Void) {
        loadLogoImageCalled = true
        completion(UIImage())
    }

    var saveQRCodeCalled: (image: UIImage?, sourceView: UIView?)?
    func saveQRCode(image: UIImage?, sourceView: UIView) {
        saveQRCodeCalled = (image, sourceView)
    }

    var copyCodeCalled = false
    func copyCode() {
        copyCodeCalled = true
    }
}
