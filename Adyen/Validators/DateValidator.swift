//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A generic validator for dates.
public final class DateValidator: Validator {

    private let formatter: DateFormatter

    /// Initializes the date validator.
    ///
    /// - Parameters:
    ///   - format: Date format.
    ///   See [Apple docs](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html)
    public init(format: Format) {
        formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
    }

    internal init(format: String) {
        formatter = DateFormatter()
        formatter.dateFormat = format
    }

    /// :nodoc:
    public func isValid(_ value: String) -> Bool {
        value.count == formatter.dateFormat.count && formatter.date(from: value) != nil
    }

    /// :nodoc:
    public func maximumLength(for _: String) -> Int {
        formatter.dateFormat.count
    }

}

extension DateValidator {

    /// Standard date formats.
    public enum Format: String {
        /// Date format for Korean Card Payment
        case kcpFormat = "yyMMdd"
    }

}
