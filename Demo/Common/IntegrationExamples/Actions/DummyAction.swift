//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Hardcoded action responses used by the standalone action examples to present action UIs
/// (e.g. `VoucherView`, `QRCodeView`) without completing a full payment flow.
internal enum DummyAction {

    internal static let voucher = """
          {
            "type" : "voucher",
            "paymentMethodType" : "boletobancario_santander",
            "totalAmount" : {
              "currency" : "BRL",
              "value" : 1
            },
            "reference" : "1234.5678.9012.3456.7890",
            "expiresAt" : "2027-12-31T23:59:59",
            "downloadUrl" : "https://adyen.com"
          }
    """

    internal static let qrCode = """
          {
            "paymentMethodType" : "pix",
            "paymentData" : "paymentData",
            "qrCodeData" : "TestQRCodeEMVToken",
            "type" : "qrCode"
          }
    """
}
