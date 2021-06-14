//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// /// Contains the styling customization options for various Action Components.
public struct AdyenActionComponentStyle {
    
    /// Indicates the UI configuration of the redirect component.
    public var redirectComponentStyle: RedirectComponentStyle
    
    /// Indicates the UI configuration of the await component.
    public var awaitComponentStyle: AwaitComponentStyle
    
    /// Indicates the UI configuration of the voucher component.
    public var voucherComponentStyle: VoucherComponentStyle
    
    /// Indicates the UI configuration of the QR code component.
    public var qrCodeComponentStyle: QRCodeComponentStyle
    
    /// Initializes the
    /// - Parameters:
    ///   - redirectComponentStyle: The UI configuration of the redirect component.
    ///   - awaitComponentStyle: The UI configuration of the await component.
    ///   - voucherComponentStyle: The UI configuration of the voucher component.
    ///   - qrCodeComponentStyle: The UI configuration of the QR code component.
    public init(
        redirectComponentStyle: RedirectComponentStyle = RedirectComponentStyle(),
        awaitComponentStyle: AwaitComponentStyle = AwaitComponentStyle(),
        voucherComponentStyle: VoucherComponentStyle = VoucherComponentStyle(),
        qrCodeComponentStyle: QRCodeComponentStyle = QRCodeComponentStyle()
    ) {
        self.redirectComponentStyle = redirectComponentStyle
        self.awaitComponentStyle = awaitComponentStyle
        self.voucherComponentStyle = voucherComponentStyle
        self.qrCodeComponentStyle = qrCodeComponentStyle
    }
}
