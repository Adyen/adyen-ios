//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal enum LocalizationMode: Equatable {
    case natural(bundle: Bundle?, tableName: String?, keySeparator: String?, locale: String?)
    case enforced(bundle: Bundle?, tableName: String?, keySeparator: String?, locale: String)
}

/// The localization parameters to control some aspects of how localized strings are fetched,
/// like the localization table to use and the separator of the key strings.
public struct LocalizationParameters: Equatable {

    internal let mode: LocalizationMode

    /// The locale identifier for external resources and numeric formats.
    /// By default current locale is used.
    public var locale: String? {
        switch mode {
        case let .natural(_, _, _, locale: locale):
            return locale
        case let .enforced(_, _, _, locale: locale):
            return locale
        }
    }

    /// The string table to search. If tableName is nil or is an empty string,
    /// the Localizable.strings is used instead.
    public var tableName: String? {
        switch mode {
        case let .natural(_, tableName: tableName, _, _):
            return tableName
        case let .enforced(_, tableName: tableName, _, _):
            return tableName
        }
    }

    /// Indicates the key separator string, set it if you want the localization keys to have a different separator other than ".",
    /// otherwise a "." is used.
    public var keySeparator: String? {
        switch mode {
        case let .natural(_, _, keySeparator: keySeparator, _):
            return keySeparator
        case let .enforced(_, _, keySeparator: keySeparator, _):
            return keySeparator
        }
    }

    /// Indicates the `Bundle` in which to look for translations,
    /// if `nil`, then the SDK try to fetch the translations from the `Bundle.main`,
    /// if not found, then the internal SDK bundle is used.
    public var bundle: Bundle? {
        switch mode {
        case let .natural(bundle: bundle, _, _, _):
            return bundle
        case let .enforced(bundle: bundle, _, _, _):
            return bundle
        }

    }
    
    /// Initializes LocalizationParameters with device specific locale.
    /// This is recommended approach for localization and it follows Apple’s [localization](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/InternationalizingYourCode/InternationalizingYourCode.html#//apple_ref/doc/uid/10000171i-CH4-SW3) guidelines.
    ///
    /// - Parameters:
    ///   - bundle: The custom bundle to search.
    ///   `Bundle.main` takes precedence over the custom bundle provided.
    ///   - tableName: The string table to search.
    ///   - keySeparator: The key separator string.
    ///   - locale: The locale for external resources and formatting of monetary values..
    public init(bundle: Bundle? = nil, tableName: String? = nil, keySeparator: String? = nil, locale: String? = nil) {
        mode = .natural(bundle: bundle, tableName: tableName, keySeparator: keySeparator, locale: locale)
    }

    /// Initializes LocalizationParameters with enforced locale.
    ///
    /// - Parameters:
    ///   - enforcedLocale: The locale to be enforced.
    ///   - bundle: The custom bundle to search.
    ///   `Bundle.main` takes precedence over the custom bundle provided.
    ///   - tableName: The string table to search.
    ///   - keySeparator: The key separator string.
    public init(enforcedLocale: String, bundle: Bundle? = nil, tableName: String? = nil, keySeparator: String? = nil) {
        mode = .enforced(bundle: bundle, tableName: tableName, keySeparator: keySeparator, locale: enforcedLocale)
    }
}
