//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package enum PhoneNumberPaymentMethod {

    case qiwiWallet

    case mbWay

    case generic
    
    case payTo

    internal var codes: [String] {
        switch self {
        case .qiwiWallet:
            return [
                "RU",
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
                "KR"
            ]
        case .mbWay:
            return ["PT", "ES"]
        case .payTo:
            return ["AU"]
        case .generic:
            return Array(allCountriesPhoneExtensions.keys).sorted { lhs, rhs in
                let localizedLhs = Locale.current.localizedString(forRegionCode: lhs) ?? lhs
                let localizedRhs = Locale.current.localizedString(forRegionCode: rhs) ?? rhs
                return localizedLhs < localizedRhs
            }
        }
    }
}

package struct PhoneExtensionsQuery {

    package let codes: [String]

    package init(codes: [String]) {
        let validator = CountryCodeValidator()
        self.codes = codes.filter { validator.isValid($0) }
    }

    package init(paymentMethod: PhoneNumberPaymentMethod) {
        self.init(codes: paymentMethod.codes)
    }
}

package enum PhoneExtensionsRepository {

    package static func get(with query: PhoneExtensionsQuery) -> [PhoneExtension] {
        query.codes.compactMap {
            guard let phoneExtension = allCountriesPhoneExtensions[$0] else {
                return nil
            }
            return PhoneExtension(
                value: phoneExtension,
                countryCode: $0
            )
        }
    }
}
