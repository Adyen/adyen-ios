//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The type of a follow-up action, as returned in the `/payments` response.
public enum ActionType: String, Decodable {

    /// The shopper is redirected to a URL in a web context.
    case redirect

    /// The shopper is redirected to a native app.
    case nativeRedirect

    /// A 3D Secure 2 flow is executed.
    case threeDS2

    /// The shopper is redirected to a third party SDK.
    case sdk

    /// A QR code is presented to the shopper.
    case qrCode

    /// The SDK waits for the shopper to complete the payment out of band.
    case `await`

    /// A voucher is presented to the shopper.
    case voucher
}
