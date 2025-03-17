//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

public protocol CardScanning {
    static func createCardScanner(
        completion: @escaping (Result<CreditCard, CardScannerError>) -> Void
    ) -> UIViewController?

    static var isAvailable: Bool { get }
}

public enum CardScanner: CardScanning {

    // MARK: - Properties

    private static let cardScannerAssembler = CardScannerAssembler()

    // MARK: - CardScanning

    public static func createCardScanner(
        completion: @escaping (Result<CreditCard, CardScannerError>) -> Void
    ) -> UIViewController? {
        let cardScannerViewController = cardScannerAssembler.resolveCardScannerViewController(completion: completion)
        return cardScannerViewController
    }

    public static var isAvailable: Bool {
        cardScannerAssembler.captureDevice != nil
    }
}
