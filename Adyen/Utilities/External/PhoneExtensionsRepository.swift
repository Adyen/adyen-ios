//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public enum PhoneNumberPaymentMethod {

    case qiwiWallet

    case mbWay

    case generic

    internal var codes: [String] {
        switch self {
        case .qiwiWallet:
            return ["RU",
                    "GE",
                    "PA",
                    "GB",
                    "TJ",
                    "LT",
                    "IL",
                    "KG",
                    "UA",
                    "VN",
                    "TR",
                    "AZ",
                    "AM",
                    "LV",
                    "IN",
                    "TH",
                    "MD",
                    "US",
                    "JP",
                    "UZ",
                    "KZ",
                    "BY",
                    "EE",
                    "RO",
                    "KR"]
        case .mbWay:
            return ["PT", "ES"]
        case .generic:
            return Array(allCountriesPhoneExtensions.keys).sorted()
        }
    }
}

@_spi(AdyenInternal)
public struct PhoneExtensionsQuery {

    public let codes: [String]

    public init(codes: [String]) {
        let validator = CountryCodeValidator()
        self.codes = codes.filter { validator.isValid($0) }
    }

    public init(paymentMethod: PhoneNumberPaymentMethod) {
        self.init(codes: paymentMethod.codes)
    }
}

@_spi(AdyenInternal)
public enum PhoneExtensionsRepository {

    public static func get(with query: PhoneExtensionsQuery) -> [PhoneExtension] {
        query.codes.compactMap {
            guard let phoneExtension = allCountriesPhoneExtensions[$0] else {
                return nil
            }
            return PhoneExtension(value: phoneExtension,
                                  countryCode: $0)
        }
    }
}
