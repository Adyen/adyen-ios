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
internal typealias CardScannerCardDetails = (number: String?, expirationDate: Date?)

internal protocol CardScannerProviding {
    func createCardScanner(completion: @escaping (Result<CardScannerCardDetails, Error>) -> Void) -> UIViewController?
}

internal protocol CardScannerControlling: CardScannerAvailability {
    func openCardScanner()
    func dismiss(completion: (() -> Void)?)
    var title: String? { get set }
    var onScanComplete: ((Result<CardScannerCardDetails, Error>) -> Void)? { get set }
}

#if canImport(AdyenCardScanner)
    import AdyenCardScanner

    @available(iOS 13.0, *)
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

        internal func createCardScanner(completion: @escaping (Result<CardScannerCardDetails, any Error>) -> Void) -> UIViewController? {

            isDispatched = false

            return self.scannerProvider.createCardScanner { result in
                guard !self.isDispatched else { return }
                self.isDispatched = true
                completion(result)
            }
        }
    }

    @available(iOS 13.0, *)
    internal struct CardScannerProviderWrapper: CardScannerProviding {
        internal func createCardScanner(completion: @escaping (Result<CardScannerCardDetails, Error>) -> Void) -> UIViewController? {

            let localizationBundle = Bundle.coreInternalResources
            return AdyenCardScanner.CardScanner.createCardScanner(
                localizationBundle: localizationBundle
            ) { result in
                switch result {
                case let .success(details): completion(.success((details.number, details.expirationDate)))
                case let .failure(error): completion(.failure(error))
                }
            }
        }
    }

    @available(iOS 13.0, *)
    internal final class CardScannerController: CardScannerControlling {
        internal enum CardScannerError: Error {
            case scanningError
        }

        private weak var presenter: UIViewController?
        private let availabilityProvider: CardScannerAvailability
        private let cardScannerProvider: CardScannerProviding
        internal var title: String?
        private let analyticsHandler: CardScannerAnalyticsHandler?

        private let scannerNavigationController: UINavigationController = {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()

            let navigationController = UINavigationController()
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.compactAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance

            return navigationController
        }()

        internal var onScanComplete: ((Result<CardScannerCardDetails, Error>) -> Void)?

        internal init(
            presenter: UIViewController,
            availabilityProvider: CardScannerAvailability = CardScannerAvailabilityWrapper(),
            cardScannerProvider: CardScannerProviding = CardScannerProviderDispatchOnce(
                scannerProvider: CardScannerProviderWrapper()
            ),
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
            guard let scannerViewController = cardScannerProvider.createCardScanner(completion: { [weak self] result in
                guard let self else { return }
                scannerNavigationController.dismiss(animated: true)
                self.onScanComplete?(map(result))
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

        internal func dismiss(completion: (() -> Void)? = nil) {
            presenter?.dismiss(animated: true, completion: completion)
        }

        // MARK: - Private

        private func map(_ result: Result<CardScannerCardDetails, Error>) -> Result<CardScannerCardDetails, Error> {
            switch result {
            case let .success(cardScanDetails):
                sendLogEvent(.cardScannerSuccess)
                return .success(cardScanDetails)
            case .failure:
                sendLogEvent(.cardScannerFailure)
                return .failure(CardScannerError.scanningError)
            }
        }

        private func makeCancelBarButton() -> UIBarButtonItem {
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCardScanningCancelation))
        }

        @objc
        private func handleCardScanningCancelation() {
            handleCardScanningCancelationWithCompletion(nil)
        }

        internal func handleCardScanningCancelationWithCompletion(_ completion: (() -> Void)?) {
            sendLogEvent(.cardScannerCancelled)
            dismiss(completion: completion)
        }

        // MARK: - Analytics

        private func sendLogEvent(_ subtype: AnalyticsEventLog.LogSubType) {
            analyticsHandler?(subtype)
        }
    }

#else // canImport(AdyenCardScanner)

    internal typealias CardScannerController = DummyCardScannerController

#endif // canImport(AdyenCardScanner)
