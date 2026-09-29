//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The type of a follow-up action, as returned in the `/payments` response.
///
/// This is a struct rather than an enum so that new action types added by Adyen do not
/// break exhaustive `switch` statements in integrating code. Always handle unknown values.
public struct ActionType: RawRepresentable, Hashable, Decodable, Sendable {

    /// The raw value as returned in the `/payments` response.
    public let rawValue: String

    /// Creates an action type with the given raw value.
    /// - Parameter rawValue: The raw value as returned in the `/payments` response.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    // MARK: - Coding

    public init(from decoder: Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    // MARK: - Known types

    /// The shopper is redirected to a URL in a web context.
    public static let redirect = ActionType(rawValue: "redirect")

    /// The shopper is redirected to a native app.
    public static let nativeRedirect = ActionType(rawValue: "nativeRedirect")

    /// A 3D Secure 2 flow is executed.
    public static let threeDS2 = ActionType(rawValue: "threeDS2")

    /// The shopper is redirected to a third party SDK.
    public static let sdk = ActionType(rawValue: "sdk")

    /// A QR code is presented to the shopper.
    public static let qrCode = ActionType(rawValue: "qrCode")

    /// The SDK waits for the shopper to complete the payment out of band.
    public static let `await` = ActionType(rawValue: "await")

    /// A voucher is presented to the shopper.
    ///
    /// BACS Direct Debit mandates are returned as a `voucher` action by the `/payments` response
    /// and are therefore surfaced with this type.
    public static let voucher = ActionType(rawValue: "voucher")
}
