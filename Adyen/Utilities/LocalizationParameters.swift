//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal enum LocalizationMode: Equatable {
    case natural(bundle: Bundle?, tableName: String?, keySeparator: String?, locale: String?)
    case enforced(locale: String)
}

/// The localization parameters to control some aspects of how localized strings are fetched,
/// like the localization table to use and the separator of the key strings.
public struct LocalizationParameters: Equatable {

    public static func == (lhs: LocalizationParameters, rhs: LocalizationParameters) -> Bool {
        lhs.mode == rhs.mode
    }

    internal let mode: LocalizationMode

    /// The locale identifier for external resources and numeric formats.
    /// By default current locale is used.
    public var locale: String? {
        switch mode {
        case .natural(bundle: _, tableName: _, keySeparator: _, locale: let locale):
            return locale
        case let .enforced(locale: locale):
            return locale
        }
    }

    /// The string table to search. If tableName is nil or is an empty string,
    /// the Localizable.strings is used instead.
    public var tableName: String? {
        switch mode {
        case let .natural(bundle: _, tableName: tableName, keySeparator: _, locale: _):
            return tableName
        default:
            return nil
        }
    }

    /// Indicates the key separator string, set it if you want the localization keys to have a different separator other than ".",
    /// otherwise a "." is used.
    public var keySeparator: String? {
        switch mode {
        case let .natural(bundle: _, tableName: _, keySeparator: keySeparator, locale: _):
            return keySeparator
        default:
            return nil
        }
    }

    /// Indicates the `Bundle` in which to look for translations,
    /// if `nil`, then the SDK try to fetch the translations from the `Bundle.main`,
    /// if not found, then the internal SDK bundle is used.
    public var bundle: Bundle? {
        switch mode {
        case let .natural(bundle: bundle, tableName: _, keySeparator: _, locale: _):
            return bundle
        default:
            return nil
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
    ///   - locale: The locale for external resources.
    public init(bundle: Bundle? = nil, tableName: String? = nil, keySeparator: String? = nil, locale: String? = nil) {
        mode = .natural(bundle: bundle, tableName: tableName, keySeparator: keySeparator, locale: locale)
    }

    /// Initializes LocalizationParameters with enforced locale.
    ///
    /// - Parameters:
    ///   - enforcedLocale: The locale to be enforced.
    public init(enforcedLocale: String) {
        mode = .enforced(locale: enforcedLocale)
    }
}
