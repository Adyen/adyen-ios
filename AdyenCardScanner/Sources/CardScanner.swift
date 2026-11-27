//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import OSLog
import UIKit

/// Details captured from a scanned card.
public typealias CardScanDetails = (number: String?, expirationDate: Date?)

/// Provides card scanning functionality.
///
/// Use `createCardScanner(localizationBundle:completion:)` to present the scanner and `isAvailable` to check device support.
/// Ensure `NSCameraUsageDescription` is set in your `Info.plist`.
///
public enum CardScanner {

    // MARK: - Properties

    private static let cardScannerAssembler = CardScannerAssembler()

    private static let logger = Logger(subsystem: "com.adyen.AdyenCardScanner", category: "CardScanner")

    // MARK: - Public interface

    /// Creates and returns a view controller that presents the card scanner interface.
    ///
    /// - Parameters:
    ///   - localizationBundle: A bundle containing localized strings used in the scanner UI.
    ///   - completion: A closure called when the scan completes, with either a `CardScanDetails` object
    ///     on success or a `CardScannerError` on failure.
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

    /// A Boolean value indicating whether card scanning is available on the current device.
    ///
    /// Scanning is unavailable when the device has no camera, or when `NSCameraUsageDescription`
    /// is missing or empty in the app's `Info.plist`.
    public static var isAvailable: Bool {
        isAvailable(
            hasCaptureDevice: cardScannerAssembler.captureDevice != nil,
            cameraUsageDescription: cameraUsageDescription()
        )
    }

    // MARK: - Internal

    internal static func isAvailable(hasCaptureDevice: Bool, cameraUsageDescription: String?) -> Bool {
        guard hasCaptureDevice else { return false }
        guard let cameraUsageDescription, !cameraUsageDescription.isEmpty else {
            logger.warning("NSCameraUsageDescription is missing or empty in Info.plist. Card scanning is unavailable.")
            return false
        }
        return true
    }

    // MARK: - Private

    private static func cameraUsageDescription() -> String? {
        Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") as? String
    }

    // swiftlint:disable line_length
    private static func assertCameraUsageDescription() {
        guard let description = cameraUsageDescription(), !description.isEmpty else {
            assertionFailure(
                "Error: NSCameraUsageDescription is missing from Info.plist. Please add a description for camera usage as required by the AdyenCardScanner SDK."
            )
            return
        }
    }
}
