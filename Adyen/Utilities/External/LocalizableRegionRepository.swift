//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Model for any geographic region.
/// :nodoc:
public struct Region: Decodable, CustomStringConvertible, Equatable {

    /// Unique identifier.
    public let identifier: String

    /// Localized human-friendly name.
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

/// Fetch localized geographic regions from external.
/// :nodoc:
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

    internal static func regions(from locale: NSLocale, countryCodes: [String]? = nil) -> [Region] {
        (countryCodes ?? NSLocale.isoCountryCodes).map { countryCode in
            Region(identifier: countryCode,
                   name: locale.displayName(forKey: .countryCode, value: countryCode) ?? countryCode)
        }
    }

    internal static func subRegions(for countryCode: String) -> [Region]? {
        allRegions[countryCode]
    }

}
