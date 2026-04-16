//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The flow types for UPI component.
public enum UPIFlowType: Int {
    
    /// Transaction handled through UPI-enabled apps.
    @available(*, deprecated, renamed: "upiIntent", message: "Use `.upiIntent` instead.")
    case upiApps = -1 // Old placeholder value

    /// Transaction initiated by scanning a QR code.
    @available(
        *,
        deprecated,
        renamed: "upiCollect",
        message: "The `.qrCode` is deprecated and not available any more. Use, `.upiIntent` instead."
    )
    case qrCode = -2 // Old placeholder value

    /// Transaction handled through UPI-enabled apps.
    case upiIntent = 0

    /// Transaction initiated by a UPI ID.
    case upiCollect = 1

    internal var value: String {
        switch self {
        case .upiIntent, .upiApps:
            return "upi_intent"
        case .upiCollect, .qrCode:
            return "upi_collect"
        }
    }
}
