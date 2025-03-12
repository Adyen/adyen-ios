//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol CardScannerControlling {
    typealias CardModel = (String?, Date?)

    var isScannerAvailable: Bool { get }
    func openCardScanner()
    
    var onScanComplete: ((Result<CardModel, Error>) -> Void)? { get set }
}

#if canImport(AdyenCardScanner)
    import AdyenCardScanner

    internal final class CardScannerController: CardScannerControlling {
        internal enum CardScannerError: Error {
            case scanningError
        }
    
        private let presenter: UIViewController
        internal var onScanComplete: ((Result<CardModel, any Error>) -> Void)?
    
        internal init(presenter: UIViewController) {
            self.presenter = presenter
        }
    
        internal var isScannerAvailable: Bool {
            if #available(iOS 13.0, *), AdyenCardScanner.CardScanner.isAvailable { true } else { false }
        }
    
        internal func openCardScanner() {
            let scannerNavigationController = UINavigationController()
            guard let scannerViewController = AdyenCardScanner.CardScanner.createCardScanner(completion: { [weak self] result in
                guard let self else { return }
                self.onScanComplete?(self.map(result))
                scannerNavigationController.dismiss(animated: true)
            }) else { return }
            
            scannerNavigationController.setViewControllers(
                [scannerViewController],
                animated: false
            )
            presenter.present(scannerNavigationController, animated: true)
        }
    
        // MARK: - Private
        
        private func map(_ result: Result<AdyenCardScanner.CreditCard, AdyenCardScanner.CardScannerError>) -> Result<CardModel, Error> {
            switch result {
            case let .success(card):
                .success((card.number, card.expirationDate))
            case .failure:
                .failure(CardScannerError.scanningError)
            }
        }
    }

#else // canImport(AdyenCardScanner)

    internal final class CardScannerController: CardScannerControlling {
        internal var isScannerAvailable: Bool { false }
        internal var onScanComplete: ((Result<CardModel, any Error>) -> Void)?
        internal func openCardScanner() {}

        internal init(onScanComplete: (@escaping (Result<CardModel, any Error>) -> Void)? = nil) {}
    }

#endif // canImport(AdyenCardScanner)
