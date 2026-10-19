//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// /// Contains the styling customization options for various Action Components.
package struct ActionComponentStyle {

    /// Indicates the UI configuration of the redirect component.
    package var redirectComponentStyle: RedirectComponentStyle

    /// Indicates the UI configuration of the await component.
    package var awaitComponentStyle: AwaitComponentStyle

    /// Indicates the UI configuration of the voucher component.
    package var voucherComponentStyle: VoucherComponentStyle

    /// Indicates the UI configuration of the QR code component.
    package var qrCodeComponentStyle: QRCodeComponentStyle

    /// Indicates the UI configuration of the document action component.
    package var documentActionComponentStyle: DocumentComponentStyle

    /// Initializes the
    /// - Parameters:
    ///   - redirectComponentStyle: The UI configuration of the redirect component.
    ///   - awaitComponentStyle: The UI configuration of the await component.
    ///   - voucherComponentStyle: The UI configuration of the voucher component.
    ///   - qrCodeComponentStyle: The UI configuration of the QR code component.
    ///   - documentActionComponentStyle: The UI configuration of the document action component.
    package init(
        redirectComponentStyle: RedirectComponentStyle = RedirectComponentStyle(),
        awaitComponentStyle: AwaitComponentStyle = AwaitComponentStyle(),
        voucherComponentStyle: VoucherComponentStyle = VoucherComponentStyle(),
        qrCodeComponentStyle: QRCodeComponentStyle = QRCodeComponentStyle(),
        documentActionComponentStyle: DocumentComponentStyle = DocumentComponentStyle()
    ) {
        self.redirectComponentStyle = redirectComponentStyle
        self.awaitComponentStyle = awaitComponentStyle
        self.voucherComponentStyle = voucherComponentStyle
        self.qrCodeComponentStyle = qrCodeComponentStyle
        self.documentActionComponentStyle = documentActionComponentStyle
    }
}
