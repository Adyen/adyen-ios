//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// UPI  payment method.
public struct UPIPaymentMethod: PaymentMethod {

    public let type: PaymentMethodType

    public let name: String

    /// The available UPI apps.
    public let apps: [Issuer]?

    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case apps
    }

}

// "apps": [
//  {
//    "id": "gpay",
//    "name": "Google Pay",
//    "appIdentifierInfo": {
//      "iosScheme": "gpay",
//      "androidPackageId": "com.gpay.app"
//    }
//  },
//  {
//    "id": "phonepe",
//    "name": "PhonePe",
//    "appIdentifierInfo": {
//      "iosScheme": "phonepe",
//      "androidPackageId": "com.phonepe.app"
//    }
//  }
// ]

internal struct UPIApp: Codable {

    internal struct AppIdentifier: Codable {
        internal let scheme: String

        enum CodingKeys: String, CodingKey {
            case scheme = "iosScheme"
        }
    }

    internal let identifier: String
    internal let name: String
    internal let appIdentifier: AppIdentifier

    // MARK: - CodingKeys

    internal enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case appIdentifier = "appIdentifierInfo"
    }
}


