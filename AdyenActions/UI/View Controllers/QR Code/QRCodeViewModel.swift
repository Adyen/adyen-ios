//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal protocol QRCodeViewModelDelegate: AnyObject {
    func saveQRCode(image: UIImage?, sourceView: UIView)
}

internal class QRCodeViewModel: Localizable {
    
    // MARK: - Properties
        
    internal let action: QRCodeAction
    internal let instruction: String
    internal var payment: Payment?
    internal let logoUrl: URL
    internal let observedProgress: Progress?
    internal let expiration: AdyenObservable<String?>
    internal let style: QRCodeViewStyle
    internal let imageLoader: ImageLoading
    internal var localizationParameters: LocalizationParameters?
    private weak var delegate: QRCodeViewModelDelegate?
    
    internal init(
        action: QRCodeAction,
        instruction: String,
        payment: Payment?,
        logoUrl: URL,
        observedProgress: Progress?,
        expiration: AdyenObservable<String?>,
        style: QRCodeViewStyle,
        imageLoader: ImageLoading = ImageLoaderProvider.imageLoader(),
        localizationParameters: LocalizationParameters?,
        delegate: QRCodeViewModelDelegate
    ) {
        self.action = action
        self.instruction = instruction
        self.payment = payment
        self.logoUrl = logoUrl
        self.observedProgress = observedProgress
        self.expiration = expiration
        self.style = style
        self.imageLoader = imageLoader
        self.localizationParameters = localizationParameters
        self.delegate = delegate
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
    
    // TODO: - Improve loading
    internal func loadLogoImage(completion: @escaping (UIImage?) -> (())) {
        imageLoader.load(url: logoUrl) { image in
            completion(image)
        }
    }

    internal func saveQRCode(image: UIImage?, sourceView: UIView) {
        delegate?.saveQRCode(image: image, sourceView: sourceView)
    }
    
    // MARK: - Content
}
