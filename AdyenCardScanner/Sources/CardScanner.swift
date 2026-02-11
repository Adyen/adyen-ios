//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Details captured from a scanned card.
public typealias CardScanDetails = (number: String?, expirationDate: Date?)

/// Provides card scanning functionality.
///
/// Use `createCardScanner(localizationBundle:completion:)` to present the scanner and `isAvailable` to check device support.
/// Ensure `NSCameraUsageDescription` is set in your `Info.plist`.
///
/// - Availability: iOS 13.0+
@available(iOS 13.0, *)
public enum CardScanner {

    // MARK: - Properties

    private static let cardScannerAssembler = CardScannerAssembler()

    // MARK: - Public interface

    /// Creates and returns a view controller that presents the card scanner interface.
    ///
    /// - Parameters:
    ///   - localizationBundle: A bundle containing localized strings used in the scanner UI.
    ///   - completion: A closure called when the scan completes, with either a `CardScanDetails` object
    ///     on success or a `CardScannerError` on failure.
    ///
    /// - Returns: A `UIViewController` that presents the card scanner, or `nil` if scanning is not available.
    public static func createCardScanner(
        localizationBundle: Bundle,
        completion: @escaping (Result<CardScanDetails, CardScannerError>) -> Void
    ) -> UIViewController? {
        assertCameraUsageDescription()
        return cardScannerAssembler.resolveCardScannerViewController(
            localizationBundle: localizationBundle,
            completion: completion
        )
    }

    /// A Boolean value indicating whether card scanning is available on the current device
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
