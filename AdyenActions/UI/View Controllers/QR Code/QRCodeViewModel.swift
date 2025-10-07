//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
@_spi(AdyenInternal) import Adyen

internal protocol QRCodeViewModelProtocol {
    var flowType: QRCodeFlowType { get }
    var instructionText: String { get }
    var amountText: String? { get }
    var actionButtonTitle: String { get }
    var qrCodeData: String { get }
    var style: QRCodeViewStyle { get }
    var expiration: AdyenObservable<String?> { get }
    var observedProgress: Progress? { get }
    
    func loadLogoImage(completion: @escaping (UIImage?) -> Void)
    func saveQRCode(image: UIImage?, sourceView: UIView)
}

internal class QRCodeViewModel: QRCodeViewModelProtocol, Localizable {
    
    // MARK: - Properties
    
    private let action: QRCodeAction
    private let logoUrl: URL
    private let imageLoader: ImageLoading
    private let onSaveQRCode: (_ image: UIImage?, _ sourceView: UIView) -> Void
    internal let observedProgress: Progress?
    internal let expiration: AdyenObservable<String?>
    internal let style: QRCodeViewStyle
    internal var localizationParameters: LocalizationParameters?
    
    internal let instructionText: String
    internal let amountText: String?
    internal let flowType: QRCodeFlowType
    
    // MARK: - Initializers
    
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
        self.instructionText = instructionText
        self.amountText = payment?.amount.formatted
        self.logoUrl = logoUrl
        self.observedProgress = observedProgress
        self.expiration = expiration
        self.style = style
        self.imageLoader = imageLoader
        self.localizationParameters = localizationParameters
        self.onSaveQRCode = onSaveQRCode
        
        self.flowType = {
            switch action.paymentMethodType {
            case .promptPay, .duitNow, .payNow, .upiQRCode: return .saveAsImage
            case .pix: return .copyCode
            }
        }()
    }

    // MARK: - Public
        
    internal var qrCodeData: String {
        action.qrCodeData
    }
    
    internal func loadLogoImage(completion: @escaping (UIImage?) -> Void) {
        imageLoader.load(url: logoUrl, completion: completion)
    }

    internal func saveQRCode(image: UIImage?, sourceView: UIView) {
        onSaveQRCode(image, sourceView)
    }
    
    // MARK: - Content
    
    internal var actionButtonTitle: String {
        switch flowType {
        case .copyCode:
            return localizedString(.pixCopyButton, localizationParameters)
        case .saveAsImage:
            return localizedString(.voucherSaveImage, localizationParameters)
        }
    }
}
