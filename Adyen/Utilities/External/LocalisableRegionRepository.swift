//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Model for any geographic region.
public struct Region: Decodable, CustomStringConvertible {

    /// Unique identifier.
    public let identifier: String

    /// Localised human-friendly name.
    public let name: String

    /// :nodoc:
    public var description: String {
        name
    }

    /// :nodoc:
    internal enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
    }
}

// swiftlint:disable type_body_length

/// Fetch localized geographic regions from external.
public class RegionRepository {

    private let environment: Environment

    private var dataTask: URLSessionDataTask?

    private static var cache = NSCache<NSURL, NSArray>()

    /// Create new instance of RegionRepository.
    /// - Parameters:
    ///   - environment: The environment to use for base URL.
    public init(environment: Environment) {
        self.environment = environment
    }

    public func getCountries(locale: String, callback: @escaping (([Region]) -> Void)) {
        let url = self.url(for: ["countries", locale])
        if let cachedValue = RegionRepository.cache.object(forKey: url as NSURL) as? [Region] {
            callback(cachedValue)
        }

        loadResurse(from: url, fallbackOption: RegionRepository.localCountryFallback, callback: callback)
    }

    public func getSubRegions(for countryCode: String, locale: String, callback: @escaping (([Region]) -> Void)) {
        let url = self.url(for: ["states", countryCode, locale])
        if let cachedValue = RegionRepository.cache.object(forKey: url as NSURL) as? [Region] {
            callback(cachedValue)
        }

        loadResurse(from: url, callback: callback)
    }

    /// https://checkoutshopper-test.adyen.com/checkoutshopper/datasets/countries/en-US.json
    /// https://checkoutshopper-test.adyen.com/checkoutshopper/datasets/states/US/ru-RU.json
    private func url(for paths: [String]) -> URL {
        let pathComponents = ["checkoutshopper", "datasets"] + paths
        let components = pathComponents.joined(separator: "/") + ".json"

        return environment.baseURL.appendingPathComponent(components)
    }

    private func loadResurse(from url: URL, fallbackOption: [Region] = [], callback: @escaping (([Region]) -> Void)) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, _, _ in
            guard
                let data = data,
                let regions = try? JSONDecoder().decode([Region].self, from: data)
            else {
                return callback(fallbackOption)
            }

            DispatchQueue.main.async {
                RegionRepository.cache.setObject(regions as NSArray, forKey: url as NSURL)
                self.dataTask = nil
                callback(regions)
            }
        }
        task.resume()
        dataTask = task
    }

    private func cancelCurrentTask() {
        dataTask?.cancel()
        dataTask = nil
    }

    internal static var localCountryFallback: [Region] { [
        Region(identifier: "AF", name: "Afghanistan"),
        Region(identifier: "AX", name: "Åland Islands"),
        Region(identifier: "AL", name: "Albania"),
        Region(identifier: "DZ", name: "Algeria"),
        Region(identifier: "AS", name: "American Samoa"),
        Region(identifier: "AD", name: "Andorra"),
        Region(identifier: "AO", name: "Angola"),
        Region(identifier: "AI", name: "Anguilla"),
        Region(identifier: "AQ", name: "Antarctica"),
        Region(identifier: "AG", name: "Antigua and Barbuda"),
        Region(identifier: "AR", name: "Argentina"),
        Region(identifier: "AM", name: "Armenia"),
        Region(identifier: "AW", name: "Aruba"),
        Region(identifier: "AU", name: "Australia"),
        Region(identifier: "AT", name: "Austria"),
        Region(identifier: "AZ", name: "Azerbaijan"),
        Region(identifier: "BS", name: "Bahamas"),
        Region(identifier: "BH", name: "Bahrain"),
        Region(identifier: "BD", name: "Bangladesh"),
        Region(identifier: "BB", name: "Barbados"),
        Region(identifier: "BY", name: "Belarus"),
        Region(identifier: "BE", name: "Belgium"),
        Region(identifier: "BZ", name: "Belize"),
        Region(identifier: "BJ", name: "Benin"),
        Region(identifier: "BM", name: "Bermuda"),
        Region(identifier: "BT", name: "Bhutan"),
        Region(identifier: "BO", name: "Bolivia"),
        Region(identifier: "BA", name: "Bosnia and Herzegovina"),
        Region(identifier: "BW", name: "Botswana"),
        Region(identifier: "BV", name: "Bouvet Island"),
        Region(identifier: "BR", name: "Brazil"),
        Region(identifier: "IO", name: "British Indian Ocean Territory"),
        Region(identifier: "BN", name: "Brunei Darussalam"),
        Region(identifier: "BG", name: "Bulgaria"),
        Region(identifier: "BF", name: "Burkina Faso"),
        Region(identifier: "BI", name: "Burundi"),
        Region(identifier: "KH", name: "Cambodia"),
        Region(identifier: "CM", name: "Cameroon"),
        Region(identifier: "CA", name: "Canada"),
        Region(identifier: "CV", name: "Cape Verde"),
        Region(identifier: "KY", name: "Cayman Islands"),
        Region(identifier: "CF", name: "Central African Republic"),
        Region(identifier: "TD", name: "Chad"),
        Region(identifier: "CL", name: "Chile"),
        Region(identifier: "CN", name: "China"),
        Region(identifier: "CX", name: "Christmas Island"),
        Region(identifier: "CC", name: "Cocos Region(Keeling) Islands"),
        Region(identifier: "CO", name: "Colombia"),
        Region(identifier: "KM", name: "Comoros"),
        Region(identifier: "CG", name: "Congo"),
        Region(identifier: "CD", name: "Congo, Democratic Republic"),
        Region(identifier: "CK", name: "Cook Islands"),
        Region(identifier: "CR", name: "Costa Rica"),
        Region(identifier: "CI", name: "Cote D\"Ivoire"),
        Region(identifier: "HR", name: "Croatia"),
        Region(identifier: "CU", name: "Cuba"),
        Region(identifier: "CY", name: "Cyprus"),
        Region(identifier: "CZ", name: "Czech Republic"),
        Region(identifier: "DK", name: "Denmark"),
        Region(identifier: "DJ", name: "Djibouti"),
        Region(identifier: "DM", name: "Dominica"),
        Region(identifier: "DO", name: "Dominican Republic"),
        Region(identifier: "EC", name: "Ecuador"),
        Region(identifier: "EG", name: "Egypt"),
        Region(identifier: "SV", name: "El Salvador"),
        Region(identifier: "GQ", name: "Equatorial Guinea"),
        Region(identifier: "ER", name: "Eritrea"),
        Region(identifier: "EE", name: "Estonia"),
        Region(identifier: "ET", name: "Ethiopia"),
        Region(identifier: "FK", name: "Falkland Islands Region(Malvinas)"),
        Region(identifier: "FO", name: "Faroe Islands"),
        Region(identifier: "FJ", name: "Fiji"),
        Region(identifier: "FI", name: "Finland"),
        Region(identifier: "FR", name: "France"),
        Region(identifier: "GF", name: "French Guiana"),
        Region(identifier: "PF", name: "French Polynesia"),
        Region(identifier: "TF", name: "French Southern Territories"),
        Region(identifier: "GA", name: "Gabon"),
        Region(identifier: "GM", name: "Gambia"),
        Region(identifier: "GE", name: "Georgia"),
        Region(identifier: "DE", name: "Germany"),
        Region(identifier: "GH", name: "Ghana"),
        Region(identifier: "GI", name: "Gibraltar"),
        Region(identifier: "GR", name: "Greece"),
        Region(identifier: "GL", name: "Greenland"),
        Region(identifier: "GD", name: "Grenada"),
        Region(identifier: "GP", name: "Guadeloupe"),
        Region(identifier: "GU", name: "Guam"),
        Region(identifier: "GT", name: "Guatemala"),
        Region(identifier: "GG", name: "Guernsey"),
        Region(identifier: "GN", name: "Guinea"),
        Region(identifier: "GW", name: "Guinea-Bissau"),
        Region(identifier: "GY", name: "Guyana"),
        Region(identifier: "HT", name: "Haiti"),
        Region(identifier: "HM", name: "Heard Island and Mcdonald Islands"),
        Region(identifier: "VA", name: "Holy See Region(Vatican City State)"),
        Region(identifier: "HN", name: "Honduras"),
        Region(identifier: "HK", name: "Hong Kong"),
        Region(identifier: "HU", name: "Hungary"),
        Region(identifier: "IS", name: "Iceland"),
        Region(identifier: "IN", name: "India"),
        Region(identifier: "ID", name: "Indonesia"),
        Region(identifier: "IR", name: "Iran"),
        Region(identifier: "IQ", name: "Iraq"),
        Region(identifier: "IE", name: "Ireland"),
        Region(identifier: "IM", name: "Isle of Man"),
        Region(identifier: "IL", name: "Israel"),
        Region(identifier: "IT", name: "Italy"),
        Region(identifier: "JM", name: "Jamaica"),
        Region(identifier: "JP", name: "Japan"),
        Region(identifier: "JE", name: "Jersey"),
        Region(identifier: "JO", name: "Jordan"),
        Region(identifier: "KZ", name: "Kazakhstan"),
        Region(identifier: "KE", name: "Kenya"),
        Region(identifier: "KI", name: "Kiribati"),
        Region(identifier: "KP", name: "Korea Region(North)"),
        Region(identifier: "KR", name: "Korea Region(South)"),
        Region(identifier: "XK", name: "Kosovo"),
        Region(identifier: "KW", name: "Kuwait"),
        Region(identifier: "KG", name: "Kyrgyzstan"),
        Region(identifier: "LA", name: "Laos"),
        Region(identifier: "LV", name: "Latvia"),
        Region(identifier: "LB", name: "Lebanon"),
        Region(identifier: "LS", name: "Lesotho"),
        Region(identifier: "LR", name: "Liberia"),
        Region(identifier: "LY", name: "Libyan Arab Jamahiriya"),
        Region(identifier: "LI", name: "Liechtenstein"),
        Region(identifier: "LT", name: "Lithuania"),
        Region(identifier: "LU", name: "Luxembourg"),
        Region(identifier: "MO", name: "Macao"),
        Region(identifier: "MK", name: "Macedonia"),
        Region(identifier: "MG", name: "Madagascar"),
        Region(identifier: "MW", name: "Malawi"),
        Region(identifier: "MY", name: "Malaysia"),
        Region(identifier: "MV", name: "Maldives"),
        Region(identifier: "ML", name: "Mali"),
        Region(identifier: "MT", name: "Malta"),
        Region(identifier: "MH", name: "Marshall Islands"),
        Region(identifier: "MQ", name: "Martinique"),
        Region(identifier: "MR", name: "Mauritania"),
        Region(identifier: "MU", name: "Mauritius"),
        Region(identifier: "YT", name: "Mayotte"),
        Region(identifier: "MX", name: "Mexico"),
        Region(identifier: "FM", name: "Micronesia"),
        Region(identifier: "MD", name: "Moldova"),
        Region(identifier: "MC", name: "Monaco"),
        Region(identifier: "MN", name: "Mongolia"),
        Region(identifier: "ME", name: "Montenegro"),
        Region(identifier: "MS", name: "Montserrat"),
        Region(identifier: "MA", name: "Morocco"),
        Region(identifier: "MZ", name: "Mozambique"),
        Region(identifier: "MM", name: "Myanmar"),
        Region(identifier: "NA", name: "Namibia"),
        Region(identifier: "NR", name: "Nauru"),
        Region(identifier: "NP", name: "Nepal"),
        Region(identifier: "NL", name: "Netherlands"),
        Region(identifier: "AN", name: "Netherlands Antilles"),
        Region(identifier: "NC", name: "New Caledonia"),
        Region(identifier: "NZ", name: "New Zealand"),
        Region(identifier: "NI", name: "Nicaragua"),
        Region(identifier: "NE", name: "Niger"),
        Region(identifier: "NG", name: "Nigeria"),
        Region(identifier: "NU", name: "Niue"),
        Region(identifier: "NF", name: "Norfolk Island"),
        Region(identifier: "MP", name: "Northern Mariana Islands"),
        Region(identifier: "NO", name: "Norway"),
        Region(identifier: "OM", name: "Oman"),
        Region(identifier: "PK", name: "Pakistan"),
        Region(identifier: "PW", name: "Palau"),
        Region(identifier: "PS", name: "Palestinian Territory, Occupied"),
        Region(identifier: "PA", name: "Panama"),
        Region(identifier: "PG", name: "Papua New Guinea"),
        Region(identifier: "PY", name: "Paraguay"),
        Region(identifier: "PE", name: "Peru"),
        Region(identifier: "PH", name: "Philippines"),
        Region(identifier: "PN", name: "Pitcairn"),
        Region(identifier: "PL", name: "Poland"),
        Region(identifier: "PT", name: "Portugal"),
        Region(identifier: "PR", name: "Puerto Rico"),
        Region(identifier: "QA", name: "Qatar"),
        Region(identifier: "RE", name: "Reunion"),
        Region(identifier: "RO", name: "Romania"),
        Region(identifier: "RU", name: "Russian Federation"),
        Region(identifier: "RW", name: "Rwanda"),
        Region(identifier: "SH", name: "Saint Helena"),
        Region(identifier: "KN", name: "Saint Kitts and Nevis"),
        Region(identifier: "LC", name: "Saint Lucia"),
        Region(identifier: "PM", name: "Saint Pierre and Miquelon"),
        Region(identifier: "VC", name: "Saint Vincent and the Grenadines"),
        Region(identifier: "WS", name: "Samoa"),
        Region(identifier: "SM", name: "San Marino"),
        Region(identifier: "ST", name: "Sao Tome and Principe"),
        Region(identifier: "SA", name: "Saudi Arabia"),
        Region(identifier: "SN", name: "Senegal"),
        Region(identifier: "RS", name: "Serbia"),
        Region(identifier: "SC", name: "Seychelles"),
        Region(identifier: "SL", name: "Sierra Leone"),
        Region(identifier: "SG", name: "Singapore"),
        Region(identifier: "SK", name: "Slovakia"),
        Region(identifier: "SI", name: "Slovenia"),
        Region(identifier: "SB", name: "Solomon Islands"),
        Region(identifier: "SO", name: "Somalia"),
        Region(identifier: "ZA", name: "South Africa"),
        Region(identifier: "GS", name: "South Georgia and the South Sandwich Islands"),
        Region(identifier: "ES", name: "Spain"),
        Region(identifier: "LK", name: "Sri Lanka"),
        Region(identifier: "SD", name: "Sudan"),
        Region(identifier: "SR", name: "Suriname"),
        Region(identifier: "SJ", name: "Svalbard and Jan Mayen"),
        Region(identifier: "SZ", name: "Swaziland"),
        Region(identifier: "SE", name: "Sweden"),
        Region(identifier: "CH", name: "Switzerland"),
        Region(identifier: "SY", name: "Syrian Arab Republic"),
        Region(identifier: "TW", name: "Taiwan, R.O.C."),
        Region(identifier: "TJ", name: "Tajikistan"),
        Region(identifier: "TZ", name: "Tanzania"),
        Region(identifier: "TH", name: "Thailand"),
        Region(identifier: "TL", name: "Timor-Leste"),
        Region(identifier: "TG", name: "Togo"),
        Region(identifier: "TK", name: "Tokelau"),
        Region(identifier: "TO", name: "Tonga"),
        Region(identifier: "TT", name: "Trinidad and Tobago"),
        Region(identifier: "TN", name: "Tunisia"),
        Region(identifier: "TR", name: "Turkey"),
        Region(identifier: "TM", name: "Turkmenistan"),
        Region(identifier: "TC", name: "Turks and Caicos Islands"),
        Region(identifier: "TV", name: "Tuvalu"),
        Region(identifier: "UG", name: "Uganda"),
        Region(identifier: "UA", name: "Ukraine"),
        Region(identifier: "AE", name: "United Arab Emirates"),
        Region(identifier: "GB", name: "United Kingdom"),
        Region(identifier: "US", name: "United States"),
        Region(identifier: "UM", name: "United States Minor Outlying Islands"),
        Region(identifier: "UY", name: "Uruguay"),
        Region(identifier: "UZ", name: "Uzbekistan"),
        Region(identifier: "VU", name: "Vanuatu"),
        Region(identifier: "VE", name: "Venezuela"),
        Region(identifier: "VN", name: "Viet Nam"),
        Region(identifier: "VG", name: "Virgin Islands, British"),
        Region(identifier: "VI", name: "Virgin Islands, U.S."),
        Region(identifier: "WF", name: "Wallis and Futuna"),
        Region(identifier: "EH", name: "Western Sahara"),
        Region(identifier: "YE", name: "Yemen"),
        Region(identifier: "ZM", name: "Zambia"),
        Region(identifier: "ZW", name: "Zimbabwe")
    ] }

}

// swiftlint:enable type_body_length
