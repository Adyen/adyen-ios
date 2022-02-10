//
// Copyright (c) 2021 Adyen N.V.
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

    /// Request list of countries, translated to a selected language.
    /// - Parameters:
    ///   - locale: The locale for translation.
    ///   - callback: The callback to receive countries.
    @available(*, deprecated, message: "This method will no longer be available.")
    public func getCountries(locale: String, callback: @escaping (([Region]) -> Void)) {
        let url = self.url(for: ["countries", locale])
        if let cachedValue = RegionRepository.cache.object(forKey: url as NSURL) as? [Region] {
            return callback(cachedValue)
        }
        let locale = NSLocale(localeIdentifier: locale)
        loadResource(from: url, fallbackOption: RegionRepository.regions(from: locale), callback: callback)
    }

    /// Request list of states or provinces for selected country, translated to a selected language.
    /// - Parameters:
    ///   - countryCode: The country code.
    ///   - locale: The locale for translation.
    ///   - callback: The callback to receive countries.
    @available(*, deprecated, message: "This method will no longer be available.")
    public func getSubRegions(for countryCode: String, locale: String, callback: @escaping (([Region]) -> Void)) {
        let url = self.url(for: ["states", countryCode, locale])
        if let cachedValue = RegionRepository.cache.object(forKey: url as NSURL) as? [Region] {
            return callback(cachedValue)
        }

        loadResource(from: url, fallbackOption: allRegions[countryCode] ?? [], callback: callback)
    }

    /// https://checkoutshopper-test.adyen.com/checkoutshopper/datasets/countries/en-US.json
    /// https://checkoutshopper-test.adyen.com/checkoutshopper/datasets/states/US/ru-RU.json
    private func url(for paths: [String]) -> URL {
        let pathComponents = ["checkoutshopper", "datasets"] + paths
        let components = pathComponents.joined(separator: "/") + ".json"

        return environment.baseURL.appendingPathComponent(components)
    }

    private func loadResource(from url: URL, fallbackOption: [Region] = [], callback: @escaping (([Region]) -> Void)) {
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

    internal func cancelCurrentTask() {
        dataTask?.cancel()
        dataTask = nil
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
