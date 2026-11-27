//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The QR code payment methods that have a dedicated QR code flow.
package enum QRCodePaymentMethodType: String, Decodable {

    /// PIX
    case pix
    
    /// PromptPay
    case promptPay = "promptpay"
    
    /// DuitNow
    case duitNow = "duitnow"
    
    /// PayNow
    case payNow = "paynow"

    /// UPI QRCode flow
    case upiQR = "upi_qr"
}

/// Describes any QR code action.
public struct QRCodeAction: PaymentDataAware, Decodable {
    
    /// The `paymentMethodType` for which the QR code is presented.
    public var paymentMethodType: PaymentMethodType {
        PaymentMethodType(rawValue: qrCodePaymentMethodType.rawValue)
    }

    package let qrCodePaymentMethodType: QRCodePaymentMethodType
    
    /// The QR code data to be shown/copied.
    public let qrCodeData: String
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String

    private enum CodingKeys: String, CodingKey {
        case qrCodePaymentMethodType = "paymentMethodType"
        case qrCodeData
        case paymentData
    }
}
