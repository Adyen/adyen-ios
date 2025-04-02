//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import SwiftUI
import UIKit

public typealias CardScanDetails = (number: String?, expirationDate: Date?)

public protocol CardScanning {
    static func createCardScanner(
        localizationBundle: Bundle,
        completion: @escaping (Result<CardScanDetails, CardScannerError>) -> Void
    ) -> UIViewController?

    static var isAvailable: Bool { get }
}

public enum CardScanner: CardScanning {

    // MARK: - Properties

    private static let cardScannerAssembler = CardScannerAssembler()

    // MARK: - CardScanning

    public static func createCardScanner(
        localizationBundle: Bundle,
        completion: @escaping (Result<CardScanDetails, CardScannerError>) -> Void
    ) -> UIViewController? {
        let cardScannerViewController = cardScannerAssembler.resolveCardScannerViewController(
            localizationBundle: localizationBundle,
            completion: completion
        )
        return cardScannerViewController
    }

    public static var isAvailable: Bool {
        cardScannerAssembler.captureDevice != nil
    }
}
