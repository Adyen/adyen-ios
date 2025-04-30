//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

public typealias CardScanDetails = (number: String?, expirationDate: Date?)

@available(iOS 13.0, *)
public protocol CardScanning {
    static func createCardScanner(
        localizationBundle: Bundle,
        completion: @escaping (Result<CardScanDetails, CardScannerError>) -> Void
    ) -> UIViewController?

    static var isAvailable: Bool { get }
}

@available(iOS 13.0, *)
public enum CardScanner: CardScanning {

    // MARK: - Properties

    private static let cardScannerAssembler = CardScannerAssembler()

    // MARK: - CardScanning

    public static func createCardScanner(
        localizationBundle: Bundle,
        completion: @escaping (Result<CardScanDetails, CardScannerError>) -> Void
    ) -> UIViewController? {
        assertCameraUsageDescription()
        let cardScannerViewController = cardScannerAssembler.resolveCardScannerViewController(
            localizationBundle: localizationBundle,
            completion: completion
        )
        return cardScannerViewController
    }

    public static var isAvailable: Bool {
        cardScannerAssembler.captureDevice != nil
    }

    // MARK: - Private

    // swiftlint:disable line_length
    private static func assertCameraUsageDescription() {
        let cameraUsageDescription = Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") as? String
        if let cameraUsageDescription, !cameraUsageDescription.isEmpty { return }

        assertionFailure(
            "Error: NSCameraUsageDescription is missing from Info.plist. Please add a description for camera usage as required by the AdyenCardScanner SDK."
        )
    }
}
