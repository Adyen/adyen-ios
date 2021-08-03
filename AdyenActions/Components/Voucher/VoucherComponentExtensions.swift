//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import PassKit
import Adyen

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
        guard let action = action else { return }
        
        switch action {
        case .dokuIndomaret, .dokuAlfamart, .econtextStores, .econtextATM:
            saveAsImage(sourceView: sourceView)
        case let .boletoBancairoSantander(action):
            presentSharePopover(with: action.downloadUrl, sourceView: sourceView)
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
        guard let action = action else { return }
        
        let view = voucherShareableViewProvider.provideView(
            with: action,
            logo: view.map(\.logo).flatMap(\.image)
        )
        
        view.frame = CGRect(origin: .zero, size: view.adyen.minimalSize)
        
        guard let image = view.adyen.snapShot() else { return }
        
        presentSharePopover(
            with: image,
            sourceView: sourceView
        )
    }
    
    private func presentOptionsAlert(sourceView: UIView) {
        guard let action = action else { return }
        
        let alert = UIAlertController(
            title: isCodeShortEnoughToBeRead ? action.anyAction.reference : nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        getAlertActions(for: action, sourceView: sourceView).forEach { alert.addAction($0) }
        
        presenterViewController.present(alert, animated: true, completion: nil)
    }
    
    private func getAlertActions(for action: VoucherAction, sourceView: UIView) -> [UIAlertAction] {
        switch action {
        case .dokuIndomaret(let genericAction):
            return getGenericAlertActions(for: genericAction, sourceView: sourceView)
        case .dokuAlfamart(let genericAction):
            return getGenericAlertActions(for: genericAction, sourceView: sourceView)
        case .econtextStores(let genericAction):
            return getGenericAlertActions(for: genericAction, sourceView: sourceView)
        case .econtextATM(let genericAction):
            return getGenericAlertActions(for: genericAction, sourceView: sourceView)
        case .boletoBancairoSantander(let boletoAction):
            return getBoletoAlertActions(for: boletoAction, sourceView: sourceView)
        }
    }
    
    private func getGenericAlertActions(for action: GenericVoucherAction, sourceView: UIView) -> [UIAlertAction] {
        [
            getCopyCodeAlertAction(for: action.reference),
            getReadInstructionsAlertAction(for: action.instructionsUrl),
            canAddPasses ? getSaveAsAnImageAlertAction(for: action, sourceView: sourceView) : nil,
            getCancelAlertAction()
        ].compactMap { $0 }
    }
    
    private func getBoletoAlertActions(for action: BoletoVoucherAction, sourceView: UIView) -> [UIAlertAction] {
        [
            getCopyCodeAlertAction(for: action.reference),
            canAddPasses ? getDownloadPDFAlertAction(for: action.downloadUrl, sourceView: sourceView) : nil,
            getCancelAlertAction()
        ].compactMap { $0 }
    }
    
    private func getCopyCodeAlertAction(for reference: String) -> UIAlertAction {
        UIAlertAction(
            title: localizedString(.pixCopyButton, localizationParameters),
            style: .default,
            handler: { [weak self] _ in self?.copyCodeSelected(reference) }
        )
    }
    
    private func getReadInstructionsAlertAction(for url: String) -> UIAlertAction? {
        guard let url = URL(string: url) else { return nil }
        
        return UIAlertAction(
            title: localizedString(.voucherReadInstructions, localizationParameters),
            style: .default,
            handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        )
    }
    
    private func getDownloadPDFAlertAction(for url: URL, sourceView: UIView) -> UIAlertAction {
        UIAlertAction(
            title: localizedString(.boletoDownloadPdf, localizationParameters),
            style: .default,
            handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        )
    }
    
    private func getSaveAsAnImageAlertAction(for action: GenericVoucherAction, sourceView: UIView) -> UIAlertAction {
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
    
    private func presentSharePopover(
        with item: Any,
        sourceView: UIView
    ) {
        let activityViewController = UIActivityViewController(
            activityItems: [item],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = sourceView
        presenterViewController.present(activityViewController, animated: true, completion: nil)
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
