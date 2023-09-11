//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import PassKit
import UIKit

/// :nodoc:
extension VoucherComponent: VoucherViewDelegate {
    
    /// :nodoc:
    private static let maximumDisplayedCodeLength = 10
    
    private var isCodeShortEnoughToBeRead: Bool {
        action
            .map(\.anyAction.reference.count)
            .map { $0 < Self.maximumDisplayedCodeLength }
            ?? false
    }
    
    internal func didComplete() {
        delegate?.didComplete(from: self)
    }
    
    internal func mainButtonTap(sourceView: UIView) {
        guard let action else { return }
        if let downloadable = action.anyAction as? DownloadableVoucher {
            presentSharePopover(with: downloadable.downloadUrl, sourceView: sourceView)
        } else {
            saveAsImage(sourceView: sourceView)
        }
    }
    
    internal func addToAppleWallet(completion: @escaping () -> Void) {
        guard let passToken = action.flatMap(\.anyAction.passCreationToken) else { return }
        
        passProvider.provide(with: passToken) { [weak self] result in
            self?.handlePassProviderResult(result, completion: completion)
        }
    }
    
    internal func secondaryButtonTap(sourceView: UIView) {
        presentOptionsAlert(sourceView: sourceView)
    }
    
    private func saveAsImage(sourceView: UIView) {
        guard let action else { return }
        
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
    
    private func presentOptionsAlert(sourceView: UIView) {
        guard let action else { return }
        
        let alert = UIAlertController(
            title: isCodeShortEnoughToBeRead ? action.anyAction.reference : nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        createAlertActions(for: action.anyAction, sourceView: sourceView).forEach { alert.addAction($0) }
        
        presenterViewController.present(alert, animated: true, completion: nil)
    }
    
    private func createAlertActions(for action: AnyVoucherAction, sourceView: UIView) -> [UIAlertAction] {
        [
            createCopyCodeAlertAction(for: action.reference),
            createSaveAlertAction(for: action, sourceView: sourceView),
            (action as? InstructionAwareVoucherAction)
                .map(\.instructionsURL)
                .flatMap(createReadInstructionsAlertAction(for:)),
            getCancelAlertAction()
        ].compactMap { $0 }
    }
    
    private func createSaveAlertAction(for action: AnyVoucherAction, sourceView: UIView) -> UIAlertAction? {
        guard canAddPasses else { return nil }
        
        if let downloadable = action as? DownloadableVoucher {
            return createDownloadPDFAlertAction(for: downloadable.downloadUrl, sourceView: sourceView)
        } else {
            return createSaveAsAnImageAlertAction(with: sourceView)
        }
    }
    
    private func createCopyCodeAlertAction(for reference: String) -> UIAlertAction {
        UIAlertAction(
            title: localizedString(.pixCopyButton, localizationParameters),
            style: .default,
            handler: { [weak self] _ in self?.copyCodeSelected(reference) }
        )
    }
    
    private func createReadInstructionsAlertAction(for url: URL) -> UIAlertAction {
        UIAlertAction(
            title: localizedString(.voucherReadInstructions, localizationParameters),
            style: .default,
            handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        )
    }
    
    private func createDownloadPDFAlertAction(for url: URL, sourceView: UIView) -> UIAlertAction {
        UIAlertAction(
            title: localizedString(.boletoDownloadPdf, localizationParameters),
            style: .default,
            handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        )
    }
    
    private func createSaveAsAnImageAlertAction(with sourceView: UIView) -> UIAlertAction {
        UIAlertAction(
            title: localizedString(.voucherSaveImage, localizationParameters),
            style: .default,
            handler: { [weak self] _ in
                self?.saveAsImage(sourceView: sourceView)
            }
        )
    }
    
    private func getCancelAlertAction() -> UIAlertAction {
        UIAlertAction(title: localizedString(.cancelButton, localizationParameters), style: .cancel, handler: nil)
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
