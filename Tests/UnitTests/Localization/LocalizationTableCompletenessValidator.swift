//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct LocalizationTableCompletenessValidator {

    struct MissingKeys: Equatable {
        let locale: String
        let keys: [String]
    }

    enum ValidationError: Error {
        case supportedLocalesNotFound(bundlePath: String)
        case tableNotFound(locale: String, tableName: String)
        case unableToLoadTable(locale: String, tableName: String)
    }

    func supportedLocales(in bundle: Bundle) throws -> [String] {
        let lprojDirectories = try FileManager.default.contentsOfDirectory(atPath: bundle.bundlePath)
            .filter { $0.hasSuffix(".lproj") && $0 != "Base.lproj" }
            .map { String($0.dropLast(".lproj".count)) }
            .sorted()

        guard lprojDirectories.isEmpty == false else {
            throw ValidationError.supportedLocalesNotFound(bundlePath: bundle.bundlePath)
        }

        return lprojDirectories
    }

    func missingKeys(
        in bundle: Bundle,
        tableName: String?,
        sourceLocale: String,
        locales: [String]? = nil
    ) throws -> [MissingKeys] {
        let localesToValidate = try locales ?? supportedLocales(in: bundle)
        let source = try localizedStrings(in: bundle, tableName: tableName, locale: sourceLocale)
        let sourceKeys = Set(source.keys)

        return try localesToValidate
            .map { locale in
                let localized = try localizedStrings(in: bundle, tableName: tableName, locale: locale)
                let missing = sourceKeys.subtracting(localized.keys).sorted()
                return MissingKeys(locale: locale, keys: missing)
            }
            .filter { $0.keys.isEmpty == false }
    }

    private func localizedStrings(
        in bundle: Bundle,
        tableName: String?,
        locale: String
    ) throws -> [String: String] {
        let resourceTableName = tableName ?? "Localizable"
        guard let path = bundle.path(
            forResource: resourceTableName,
            ofType: "strings",
            inDirectory: nil,
            forLocalization: locale
        ) else {
            throw ValidationError.tableNotFound(locale: locale, tableName: resourceTableName)
        }

        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: String] else {
            throw ValidationError.unableToLoadTable(locale: locale, tableName: resourceTableName)
        }

        return dictionary
    }
}
