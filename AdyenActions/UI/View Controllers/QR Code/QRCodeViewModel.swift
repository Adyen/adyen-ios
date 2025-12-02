//
// Copyright (c) 2021 Adyen N.V.
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
    var onCopyButtonTitle: String { get }
    var qrCodeData: String { get }
    var expiration: AdyenObservable<String?> { get }
    var copyInProgress: AdyenObservable<Bool> { get }
    var observedProgress: Progress? { get }
    
    func loadLogoImage(completion: @escaping (UIImage?) -> Void)
    func performAction(qrCodeImage: UIImage?, from: UIView)
}

internal class QRCodeViewModel: QRCodeViewModelProtocol, Localizable {
    
    private enum Constants {
        static let copyAnimationDuration: TimeInterval = 2
    }
    
    // MARK: - Properties
        
    private let action: QRCodeAction
    private let logoUrl: URL
    private let imageLoader: ImageLoading
    private let onSaveQRCode: (_ image: UIImage?, _ sourceView: UIView) -> Void
    private let onCopyCode: (_ code: String) -> Void
    internal let observedProgress: Progress?
    internal let expiration: AdyenObservable<String?>
    internal var copyInProgress: AdyenObservable<Bool> = .init(false)
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
        imageLoader: ImageLoading = ImageLoaderProvider.imageLoader(),
        localizationParameters: LocalizationParameters?,
        onSaveQRCode: @escaping (_ image: UIImage?, _ sourceView: UIView) -> Void,
        onCopyCode: @escaping (_ code: String) -> Void
    ) {
        self.action = action
        self.instructionText = instructionText
        self.amountText = payment?.amount.formatted
        self.logoUrl = logoUrl
        self.observedProgress = observedProgress
        self.expiration = expiration
        self.imageLoader = imageLoader
        self.localizationParameters = localizationParameters
        self.onSaveQRCode = onSaveQRCode
        self.onCopyCode = onCopyCode
        
        self.flowType = {
            switch action.paymentMethodType {
            case .promptPay, .duitNow, .payNow, .upiQRCode: return .saveCodeAsImage
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
    
    internal func performAction(qrCodeImage: UIImage?, from view: UIView) {
        switch flowType {
        case .copyCode:
            enableCopyInProgress(for: Constants.copyAnimationDuration)
            onCopyCode(qrCodeData)
        case .saveCodeAsImage:
            guard let qrCodeImage else { return }
            onSaveQRCode(qrCodeImage, view)
        }
    }
    
    // MARK: - Content
    
    private func enableCopyInProgress(for timeInterval: TimeInterval) {
        copyInProgress.wrappedValue = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) { [weak self] in
            self?.copyInProgress.wrappedValue = false
        }
    }
    
    internal var actionButtonTitle: String {
        switch flowType {
        case .copyCode:
            return localizedString(.pixCodeCopyLabel, localizationParameters)
        case .saveCodeAsImage:
            return localizedString(.voucherSaveImage, localizationParameters)
        }
    }
    
    internal var onCopyButtonTitle: String {
        switch flowType {
        case .copyCode:
            return localizedString(.pixCodeCopiedLabel, localizationParameters)
        case .saveCodeAsImage:
            return localizedString(.voucherSaveImage, localizationParameters)
        }
    }
}
