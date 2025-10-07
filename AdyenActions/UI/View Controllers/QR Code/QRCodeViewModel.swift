//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
@_spi(AdyenInternal) import Adyen

internal class QRCodeViewModel: Localizable {
    
    // MARK: - Properties
        
    private let action: QRCodeAction
    private let instruction: String
    private var payment: Payment?
    private let logoUrl: URL
    internal let observedProgress: Progress?
    internal let expiration: AdyenObservable<String?>
    internal let style: QRCodeViewStyle
    private let imageLoader: ImageLoading
    internal var localizationParameters: LocalizationParameters?
    private let onSaveQRCode: (_ image: UIImage?, _ sourceView: UIView) -> Void
    
    internal init(
        action: QRCodeAction,
        instructionText: String,
        payment: Payment?,
        logoUrl: URL,
        observedProgress: Progress?,
        expiration: AdyenObservable<String?>,
        style: QRCodeViewStyle,
        imageLoader: ImageLoading = ImageLoaderProvider.imageLoader(),
        localizationParameters: LocalizationParameters?,
        onSaveQRCode: @escaping (_ image: UIImage?, _ sourceView: UIView) -> Void
    ) {
        self.action = action
        self.instruction = instructionText
        self.payment = payment
        self.logoUrl = logoUrl
        self.observedProgress = observedProgress
        self.expiration = expiration
        self.style = style
        self.imageLoader = imageLoader
        self.localizationParameters = localizationParameters
        self.onSaveQRCode = onSaveQRCode
    }
    
    // MARK: - Public
    
    internal var flowType: QRCodeFlowType {
        switch action.paymentMethodType {
        case .promptPay, .duitNow, .payNow, .upiQRCode:
            return .saveAsImage
        case .pix:
            return .copyCode
        }
    }
    
    internal var qrCodeData: String {
        action.qrCodeData
    }
    
    internal func loadLogoImage(completion: @escaping (UIImage?) -> (())) {
        imageLoader.load(url: logoUrl) { image in
            completion(image)
        }
    }

    internal func saveQRCode(image: UIImage?, sourceView: UIView) {
        onSaveQRCode(image, sourceView)
    }
    
    // MARK: - Content
    
    internal var instructionText: String {
        instruction
    }
    
    internal var amountText: String? {
        payment?.amount.formatted
    }
    
    internal var actionButtonTitle: String {
        switch flowType {
        case .copyCode:
            return localizedString(.pixCopyButton, localizationParameters)
        case .saveAsImage:
            return localizedString(.voucherSaveImage, localizationParameters)
        }
    }
}
