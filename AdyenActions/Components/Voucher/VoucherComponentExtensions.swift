//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import PassKit
import UIKit

@_spi(AdyenInternal)
extension VoucherComponent: VoucherViewDelegate, DocumentActionViewDelegate {
    
    private static let maximumDisplayedCodeLength = 10
    
    private func isCodeShortEnoughToBeRead(action: VoucherAction) -> Bool {
        action.anyAction.reference.count < Self.maximumDisplayedCodeLength
    }
    
    internal func didComplete() {
        delegate?.didComplete(from: self)
    }
    
    internal func mainButtonTap(sourceView: UIView, action: VoucherAction) {
        if let downloadable = action.anyAction as? Downloadable {
            mainButtonTap(sourceView: sourceView, downloadable: downloadable)
        } else {
            saveAsImage(sourceView: sourceView, action: action)
        }
    }
    
    internal func mainButtonTap(sourceView: UIView, downloadable: Downloadable) {
        presentSharePopover(with: downloadable.downloadUrl, sourceView: sourceView)
    }
    
    internal func addToAppleWallet(action: VoucherAction, completion: @escaping () -> Void) {
        guard let passToken = action.anyAction.passCreationToken else { return }
        
        passProvider.provide(with: passToken) { [weak self] result in
            self?.handlePassProviderResult(result, completion: completion)
        }
    }
    
    internal func secondaryButtonTap(sourceView: UIView, action: VoucherAction) {
        presentOptionsAlert(sourceView: sourceView, action: action)
    }
    
    private func saveAsImage(sourceView: UIView, action: VoucherAction) {
        
        let shareableView = voucherShareableViewProvider.provideView(
            with: action,
            logo: view.map(\.logo).flatMap(\.image)
        )
        
        shareableView.frame = CGRect(origin: .zero, size: shareableView.adyen.minimalSize)

        guard let image = shareableView.adyen.snapShot(forceRedraw: true) else { return }

        presentSharePopover(
            with: image,
            sourceView: sourceView
        )
    }
    
    private func presentOptionsAlert(sourceView: UIView, action: VoucherAction) {
        
        let alert = UIAlertController(
            title: isCodeShortEnoughToBeRead(action: action) ? action.anyAction.reference : nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        createAlertActions(for: action, sourceView: sourceView).forEach { alert.addAction($0) }
        
        presenterViewController.present(alert, animated: true, completion: nil)
    }
    
    private func createAlertActions(for action: VoucherAction, sourceView: UIView) -> [UIAlertAction] {
        [
            createCopyCodeAlertAction(for: action.anyAction.reference),
            createSaveAlertAction(for: action, sourceView: sourceView),
            (action.anyAction as? InstructionAwareVoucherAction)
                .map(\.instructionsURL)
                .flatMap(createReadInstructionsAlertAction(for:)),
            getCancelAlertAction()
        ].compactMap { $0 }
    }
    
    private func createSaveAlertAction(for action: VoucherAction, sourceView: UIView) -> UIAlertAction? {
        guard canAddPasses(action: action.anyAction) else { return nil }
        
        if let downloadable = action.anyAction as? Downloadable {
            return createDownloadPDFAlertAction(for: downloadable.downloadUrl, sourceView: sourceView)
        } else {
            return createSaveAsAnImageAlertAction(with: sourceView, action: action)
        }
    }
    
    private func createCopyCodeAlertAction(for reference: String) -> UIAlertAction {
        UIAlertAction(
            title: localizedString(.pixCopyButton, configuration.localizationParameters),
            style: .default,
            handler: { [weak self] _ in self?.copyCodeSelected(reference) }
        )
    }
    
    private func createReadInstructionsAlertAction(for url: URL) -> UIAlertAction {
        UIAlertAction(
            title: localizedString(.voucherReadInstructions, configuration.localizationParameters),
            style: .default,
            handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        )
    }
    
    private func createDownloadPDFAlertAction(for url: URL, sourceView: UIView) -> UIAlertAction {
        UIAlertAction(
            title: localizedString(.boletoDownloadPdf, configuration.localizationParameters),
            style: .default,
            handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        )
    }
    
    private func createSaveAsAnImageAlertAction(with sourceView: UIView, action: VoucherAction) -> UIAlertAction {
        UIAlertAction(
            title: localizedString(.voucherSaveImage, configuration.localizationParameters),
            style: .default,
            handler: { [weak self] _ in
                self?.saveAsImage(sourceView: sourceView, action: action)
            }
        )
    }
    
    private func getCancelAlertAction() -> UIAlertAction {
        UIAlertAction(title: localizedString(.cancelButton, configuration.localizationParameters), style: .cancel, handler: nil)
    }
    
    private func copyCodeSelected(_ code: String) {
        UIPasteboard.general.string = code
        view?.showCopyCodeConfirmation()
    }
    
    private func handlePassProviderResult(_ result: Result<Data, Swift.Error>,
                                          completion: @escaping () -> Void) {
        switch result {
        case let .failure(error):
            delegate?.didFail(with: error, from: self)
        case let .success(data):
            showAppleWallet(passData: data, completion: completion)
        }
    }
    
    private func showAppleWallet(passData: Data?, completion: @escaping () -> Void) {
        do {
            guard let data = passData else { throw AppleWalletError.failedToAddToAppleWallet }
            
            let pass = try PKPass(data: data)
            if let viewController = PKAddPassesViewController(pass: pass) {
                presenterViewController.present(viewController, animated: true) {
                    completion()
                }
            } else {
                throw AppleWalletError.failedToAddToAppleWallet
            }
        } catch {
            completion()
            delegate?.didFail(with: error, from: self)
        }
    }
}
