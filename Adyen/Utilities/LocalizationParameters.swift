//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The localization parameters to control some aspects of how localized strings are fetched,
/// like the localization table to use and the separator of the key strings.
public struct LocalizationParameters: Equatable {

    internal let enforcedLocale: String?

    /// The locale identifier for external resources.
    /// By default current locale is used.
    public let locale: String
    
    /// The string table to search. If tableName is nil or is an empty string,
    /// the Localizable.strings is used instead.
    public let tableName: String?
    
    /// Indicates the key separator string, set it if you want the localization keys to have a different separator other than ".",
    /// otherwise a "." is used.
    public let keySeparator: String?

    /// Indicates the `Bundle` in which to look for translations,
    /// if `nil`, then the SDK try to fetch the translations from the `Bundle.main`,
    /// if not found, then the internal SDK bundle is used.
    public let bundle: Bundle?
    
    /// Initializes LocalizationParameters with device specific locale.
    /// This is recommended approach for localization and it follows Apple’s [localization](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/InternationalizingYourCode/InternationalizingYourCode.html#//apple_ref/doc/uid/10000171i-CH4-SW3) guidlines.
    ///
    /// - Parameters:
    ///   - bundle: The custom bundle to search.
    ///   `Bundle.main` takes precedence over the custom bundle provided.
    ///   - tableName: The string table to search.
    ///   - keySeparator: The key separator string.
    ///   - locale: The locale for external resources.
    public init(bundle: Bundle? = nil, tableName: String? = nil, keySeparator: String? = nil, locale: String? = nil) {
        self.bundle = bundle
        self.tableName = tableName
        self.keySeparator = keySeparator
        self.locale = locale ?? Locale.current.identifier
        self.enforcedLocale = nil
    }

    /// Initializes LocalizationParameters with enforced locale.
    ///
    /// - Parameters:
    ///   - locale: The locale to be enforced.
    public init(locale: String) {
        self.bundle = nil
        self.tableName = nil
        self.keySeparator = nil
        self.enforcedLocale = locale
        self.locale = locale
    }
}
