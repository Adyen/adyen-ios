//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal final class DummyCardScannerController: CardScannerControlling {
    internal var isScannerAvailable: Bool {
        false
    }

    internal var onScanComplete: ((Result<CardScannerCardDetails, any Error>) -> Void)?
    internal var title: String?
    internal func openCardScanner() { /* Empty implementation */ }
    internal func dismiss(completion: (() -> Void)? = nil) { /* Empty implementation */ }

    internal init(
        presenter: UIViewController,
        availabilityProvider: CardScannerAvailability = DummyCardScannerAvailability(),
        cardScannerProvider: CardScannerProviding = DummyCardScannerProvider(),
        analyticsHandler: CardScannerAnalyticsHandler?
    ) {}

    // MARK: - Helpers

    internal struct DummyCardScannerAvailability: CardScannerAvailability {
        internal var isScannerAvailable: Bool {
            false
        }
    }

    internal struct DummyCardScannerProvider: CardScannerProviding {
        internal func createCardScanner(
            completion: @escaping (Result<CardScannerCardDetails, any Error>) -> Void
        ) -> UIViewController? {
            UIViewController()
        }
    }
}
