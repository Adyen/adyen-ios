//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Indicates QR code payment methods.
public enum QRCodePaymentMethod: String, Codable, CaseIterable {

    /// PIX
    case pix
    
}

/// Describes any QR code action.
public struct QRCodeAction: PaymentDataAware, Decodable {
    
    /// The `paymentMethodType` for which the QR code is presented.
    public let paymentMethodType: QRCodePaymentMethod
    
    /// The QR code data to be shown/copied.
    public let qrCodeData: String
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String
    
}
