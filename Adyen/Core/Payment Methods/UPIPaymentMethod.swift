//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// UPI  payment method.
public struct UPIPaymentMethod: PaymentMethod {

    // TODO: - We mock the response for testing purposes until the backend changes are done.
    // Backend Ticket: https://youtrack.is.adyen.com/issue/APIG-105/paymentMethods-upi-app-list-enhancement
    // ============================= MOCK =============================

    private static let appsResponse =
        """
        {
            "apps": [
              {
                "id": "gpay",
                "name": "Google Pay",
                "appIdentifierInfo": {
                  "iosScheme": "gpay",
                  "androidPackageId": "com.gpay.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              },
              {
                "id": "phonepe",
                "name": "PhonePe",
                "appIdentifierInfo": {
                  "iosScheme": "phonepe",
                  "androidPackageId": "com.phonepe.app"
                }
              }
            ]
        }
        """

    internal struct AppsResponse: Codable {
        internal let apps: [UPIApp]
    }

    private static var appsMock: [UPIApp]? {
        let data = Data(Self.appsResponse.utf8)
        let decoder = JSONDecoder()
        let response = try? decoder.decode(AppsResponse.self, from: data)
        return response?.apps
    }

    // ============================= MOCK =============================

    public let type: PaymentMethodType

    public let name: String

    /// The available UPI apps.
    public let apps: [UPIApp]? = Self.appsMock

    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        //        case apps
    }
}

public struct UPIApp: Codable {

    public struct AppIdentifier: Codable {
        public let scheme: String

        public enum CodingKeys: String, CodingKey {
            case scheme = "iosScheme"
        }
    }

    public let identifier: String
    public let name: String
    public let appIdentifier: AppIdentifier

    // MARK: - CodingKeys

    public enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case appIdentifier = "appIdentifierInfo"
    }
}
