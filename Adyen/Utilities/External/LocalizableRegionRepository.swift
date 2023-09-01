//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Model for any geographic region.
@_spi(AdyenInternal)
public struct Region: Decodable, CustomStringConvertible, Equatable {

    /// Unique identifier.
    public let identifier: String

    /// Localized human-friendly name.
    public let name: String

    public var description: String {
        name
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
    }
}

/// Fetch localized geographic regions from external.
enum RegionRepository {

    static func regions(
        from locale: NSLocale,
        with countryCodes: [String]? = nil
    ) -> [Region] {
        (countryCodes ?? NSLocale.isoCountryCodes).map { countryCode in
            Region(identifier: countryCode,
                   name: locale.displayName(forKey: .countryCode, value: countryCode) ?? countryCode)
        }
    }

    static func subRegions(for countryCode: String) -> [Region]? {
        allRegions[countryCode]
    }
    
    static func region(
        from locale: NSLocale,
        for countryCode: String
    ) -> Region? {
        RegionRepository.regions(from: locale).first { region in region.identifier == countryCode }
    }

}
