//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

internal protocol CardScannerAvailability {
    var isScannerAvailable: Bool { get }
}

internal typealias CardScannerAnalyticsHandler = (_ subtype: AnalyticsEventLog.LogSubType) -> Void
internal typealias CardScanDetails = (number: String?, expirationDate: Date?)

internal protocol CardScannerProviding {
    func createCardScanner(completion: @escaping (Result<CardScanDetails, Error>) -> Void) -> UIViewController?
}

internal protocol CardScannerControlling: CardScannerAvailability {

    init(
        presenter: UIViewController,
        availabilityProvider: CardScannerAvailability,
        cardScannerProvider: CardScannerProviding,
        analyticsHandler: @escaping CardScannerAnalyticsHandler
    )
    func openCardScanner()
    var title: String? { get set }
    var onScanComplete: ((Result<CardScanDetails, Error>) -> Void)? { get set }
}

#if canImport(AdyenCardScanner)
    import AdyenCardScanner

    private struct CardScannerAvailabilityWrapper: CardScannerAvailability {
        var isScannerAvailable: Bool {
            AdyenCardScanner.CardScanner.isAvailable
        }
    }

    internal class CardScannerProviderDispatchOnce: CardScannerProviding {
        private let scannerProvider: CardScannerProviding

        internal init(scannerProvider: CardScannerProviding) {
            self.scannerProvider = scannerProvider
        }

        private var isDispatched = false

        private var completion: ((Result<CardScanDetails, any Error>) -> Void)?

        internal func createCardScanner(completion: @escaping (Result<CardScanDetails, any Error>) -> Void) -> UIViewController? {
            self.scannerProvider.createCardScanner { result in
                guard !self.isDispatched else { return }
                self.isDispatched = true
                completion(result)
            }
        }
    }

    internal struct CardScannerProviderWrapper: CardScannerProviding {
        internal func createCardScanner(completion: @escaping (Result<CardScanDetails, Error>) -> Void) -> UIViewController? {

            let localizationBundle = Bundle.coreInternalResources
            let cardScannerViewController = AdyenCardScanner.CardScanner.createCardScanner(
                localizationBundle: localizationBundle
            ) { result in
                switch result {
                case let .success(details): completion(.success((details.number, details.expirationDate)))
                case let .failure(error): completion(.failure(error))
                }
            }

            return cardScannerViewController
        }
    }

    internal final class CardScannerController: CardScannerControlling {
        internal enum CardScannerError: Error {
            case scanningError
        }

        private weak var presenter: UIViewController?
        private let availabilityProvider: CardScannerAvailability
        private let cardScannerProvider: CardScannerProviding
        internal var title: String?
        private let analyticsHandler: CardScannerAnalyticsHandler?

        internal var onScanComplete: ((Result<CardScanDetails, Error>) -> Void)?

        internal init(
            presenter: UIViewController,
            availabilityProvider: CardScannerAvailability = CardScannerAvailabilityWrapper(),
            cardScannerProvider: CardScannerProviding = CardScannerProviderDispatchOnce(
                scannerProvider: CardScannerProviderWrapper()),
            analyticsHandler: @escaping CardScannerAnalyticsHandler
        ) {
            self.presenter = presenter
            self.availabilityProvider = availabilityProvider
            self.cardScannerProvider = cardScannerProvider
            self.analyticsHandler = analyticsHandler

            if isScannerAvailable {
                sendLogEvent(.cardScannerAvailable)
            } else {
                sendLogEvent(.cardScannerUnavailable)
            }
        }

        internal var isScannerAvailable: Bool {
            guard #available(iOS 13.0, *) else { return false }
            return availabilityProvider.isScannerAvailable
        }

        internal func openCardScanner() {
            let scannerNavigationController = makeNavigationController()
            guard let scannerViewController = cardScannerProvider.createCardScanner(completion: { [weak self] result in
                guard let self else { return }
                self.onScanComplete?(map(result))
                scannerNavigationController.dismiss(animated: true)
            }) else { return }

            scannerViewController.navigationItem.leftBarButtonItem = makeCancelBarButton()
            scannerViewController.title = title

            scannerNavigationController.setViewControllers(
                [scannerViewController],
                animated: false
            )

            presenter?.present(scannerNavigationController, animated: true)
            sendLogEvent(.cardScannerPresented)
        }

        // MARK: - Private

        private func map(_ result: Result<CardScanDetails, Error>) -> Result<CardScanDetails, Error> {
            switch result {
            case let .success(cardScanDetails):
                sendLogEvent(.cardScannerSuccess)
                return .success(cardScanDetails)
            case .failure:
                sendLogEvent(.cardScannerFailure)
                return .failure(CardScannerError.scanningError)
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

        @objc
        private func handleCardScanningCancelation() {
            sendLogEvent(.cardScannerCancelled)
            handleCardScanningCancelationWithCompletion(nil)
        }

        @objc
        internal func handleCardScanningCancelationWithCompletion(_ completion: (() -> Void)?) {
            presenter?.presentedViewController?.dismiss(animated: true, completion: completion)
        }

        // MARK: - Analytics

        private func sendLogEvent(_ subtype: AnalyticsEventLog.LogSubType) {
            analyticsHandler?(subtype)
        }
    }

#else // canImport(AdyenCardScanner)

    internal final class CardScannerController: CardScannerControlling {
        internal var isScannerAvailable: Bool { false }
        internal var onScanComplete: ((Result<CardScanDetails, any Error>) -> Void)?
        internal var title: String?
        internal func openCardScanner() {}

        internal init(
            presenter: UIViewController,
            availabilityProvider: CardScannerAvailability = DummyCardScannerAvailability(),
            cardScannerProvider: CardScannerProviding = DummyCardScannerProvider()
        ) {}

        // MARK: - Helpers

        internal struct DummyCardScannerAvailability: CardScannerAvailability {
            internal var isScannerAvailable: Bool { false }
        }

        internal struct DummyCardScannerProvider: CardScannerProviding {
            internal func createCardScanner(
                completion: @escaping (Result<CardScanDetails, any Error>) -> Void
            ) -> UIViewController? {
                UIViewController()
            }
        }
    }

#endif // canImport(AdyenCardScanner)
