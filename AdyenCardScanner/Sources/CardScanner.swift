//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

public typealias CardScanDetails = (number: String?, expirationDate: Date?)

/// A protocol that defines an interface for presenting a view controller to scan payment cards.
///
/// Types that conform to the `CardScanning` protocol provide functionality to create a card scanning
/// view controller and report whether scanning is currently supported on the device.
///
/// You typically use this protocol to integrate card scanning into your app’s payment or onboarding flows.
///
/// - Note: Card scanning is available only on supported devices running iOS 13.0 or later.
@available(iOS 13.0, *)
public protocol CardScanning {

    /// Creates and returns a view controller that presents the card scanner interface.
    ///
    /// - Parameters:
    ///   - localizationBundle: A bundle containing localized strings used in the scanner UI.
    ///   - completion: A closure called when the scan completes, with either a `CardScanDetails` object
    ///     on success or a `CardScannerError` on failure.
    ///
    /// - Returns: A `UIViewController` that presents the card scanner, or `nil` if scanning is not available.
    static func createCardScanner(
        localizationBundle: Bundle,
        completion: @escaping (Result<CardScanDetails, CardScannerError>) -> Void
    ) -> UIViewController?

    /// A Boolean value indicating whether card scanning is available on the current device.
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
