//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The localization parameters to control some aspects of how localized strings are fetched,
/// like the localization table to use and the separator of the key strings.
public struct LocalizationParameters: Equatable {
    
    /// The string table to search. If tableName is nil or is an empty string,
    /// the Localizable.strings is used instead.
    public let tableName: String?
    
    /// Indicates the key separator string, set it if you want the localization keys to have a different separator other than ".",
    /// otherwise a "." is used.
    public let keySeparator: String?
    
    /// Initializes an LocalizationParameters.
    ///
    /// - Parameters:
    ///   - tableName: The string table to search.
    ///   - keySeparator: The key separator string.
    public init(tableName: String? = nil, keySeparator: String? = nil) {
        self.tableName = tableName
        self.keySeparator = keySeparator
    }
}
