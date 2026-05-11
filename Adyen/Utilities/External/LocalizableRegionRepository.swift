//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Model for any geographic region.
package struct Region: Decodable, CustomStringConvertible, Equatable {

    /// Unique identifier.
    package let identifier: String

    /// Localized human-friendly name.
    package let name: String

    package var description: String {
        name
    }

    internal enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
    }
}

/// Fetch localized geographic regions from external.
package enum RegionRepository {

    package static func regions(
        from locale: NSLocale,
        with countryCodes: [String]? = nil
    ) -> [Region] {
        (countryCodes ?? NSLocale.isoCountryCodes).map { countryCode in
            Region(
                identifier: countryCode,
                name: locale.displayName(forKey: .countryCode, value: countryCode) ?? countryCode
            )
        }
    }

    package static func subRegions(for countryCode: String) -> [Region]? {
        allRegions[countryCode]
    }
    
    internal static func region(
        from locale: NSLocale,
        for countryCode: String
    ) -> Region? {
        RegionRepository.regions(from: locale).first { region in region.identifier == countryCode }
    }

}
