//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol ExpirationDateFormatting {
    func date(from string: String) -> Date?
}

internal class ExpirationDateFormatter: ExpirationDateFormatting {

    private enum ExpirationDateFormat {
        static let short = "MM/yy"
        static let long = "MM/yyyy"
    }

    // MARK: - Properties

    private let shortDateFormatter = DateFormatter()
    private let longFormatter = DateFormatter()

    // MARK: - Initializers

    internal init() {
        let locale = Locale.current
        let timeZone = TimeZone(secondsFromGMT: 0)

        shortDateFormatter.locale = locale
        shortDateFormatter.timeZone = timeZone
        shortDateFormatter.dateFormat = ExpirationDateFormat.short

        longFormatter.locale = locale
        longFormatter.timeZone = timeZone
        longFormatter.dateFormat = ExpirationDateFormat.long
    }

    // MARK: - ExpireDateFormatting

    internal func date(from string: String) -> Date? {
        // First, try the short ("MM/YY") format
        if let shortDate = shortDateFormatter.date(from: string) {
            return shortDate
        }

        // Then, try the long ("MM/YYYY") format
        return longFormatter.date(from: string)
    }
}
