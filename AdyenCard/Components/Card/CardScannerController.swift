//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal protocol CardScannerAvailability {
    var isScannerAvailable: Bool { get }
}

internal protocol CardScannerProviding {
    func createCardScanner(completion: @escaping (Result<CreditCard, CardScannerError>) -> Void) -> UIViewController?
}

internal protocol CardScannerControlling: CardScannerAvailability {
    typealias CardModel = (String?, Date?)

    init(presenter: UIViewController, availabilityProvider: CardScannerAvailability, cardScannerProvider: CardScannerProviding)
    func openCardScanner()

    var onScanComplete: ((Result<CardModel, Error>) -> Void)? { get set }
}

#if canImport(AdyenCardScanner)
    import AdyenCardScanner

    private struct CardScannerAvailabilityWrapper: CardScannerAvailability {
        var isScannerAvailable: Bool { AdyenCardScanner.CardScanner.isAvailable }
    }

    private struct CardScannerProviderWrapper: CardScannerProviding {
        func createCardScanner(completion: @escaping (Result<CreditCard, CardScannerError>) -> Void) -> UIViewController? {
            AdyenCardScanner.CardScanner.createCardScanner(completion: completion)
        }
    }

    internal final class CardScannerController: CardScannerControlling {
        internal enum CardScannerError: Error {
            case scanningError
        }
    
        private let presenter: UIViewController
        private let availabilityProvider: CardScannerAvailability
        private let cardScannerProvider: CardScannerProviding
        internal var title: String?

        internal var onScanComplete: ((Result<(String?, Date?), any Error>) -> Void)?
    
        internal init(
            presenter: UIViewController,
            availabilityProvider: CardScannerAvailability = CardScannerAvailabilityWrapper(),
            cardScannerProvider: CardScannerProviding = CardScannerProviderWrapper()
        ) {
            self.availabilityProvider = availabilityProvider
            self.cardScannerProvider = cardScannerProvider
            self.presenter = presenter
        }
    
        internal var isScannerAvailable: Bool {
            if #available(iOS 13.0, *), availabilityProvider.isScannerAvailable { true } else { false }
        }
    
        internal func openCardScanner() {
            let scannerNavigationController = makeNavigationController()
            guard let scannerViewController = cardScannerProvider.createCardScanner(completion: { [weak self] result in
                guard let self else { return }
                self.onScanComplete?(self.map(result))
                scannerNavigationController.dismiss(animated: true)
            }) else { return }

            scannerViewController.navigationItem.leftBarButtonItem = makeCancelBarButton()
            scannerViewController.title = title

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

        private func makeNavigationController() -> UINavigationController {
            guard #available(iOS 13.0, *) else { return UINavigationController() }

            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()

            let navigationController = UINavigationController()
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.compactAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance

            return navigationController
        }

        private func makeCancelBarButton() -> UIBarButtonItem {
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCardScanningCancelation))
        }

        @objc internal func handleCardScanningCancelation(completion: (() -> Void)? = nil) {
            presenter.presentedViewController?.dismiss(animated: true, completion: completion)
//            presenter.navigationController?.topViewController?.dismiss(animated: true)
        }
    }

#else // canImport(AdyenCardScanner)

    internal final class CardScannerController: CardScannerControlling {
        internal var isScannerAvailable: Bool { false }
        internal var onScanComplete: ((Result<CardModel, any Error>) -> Void)?
        internal func openCardScanner(title: String?) {}

        internal init(presenter: UIViewController) {}
    }

#endif // canImport(AdyenCardScanner)
