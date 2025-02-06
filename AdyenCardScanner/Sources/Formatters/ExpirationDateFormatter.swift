//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

protocol ExpirationDateFormatting {
    func date(from string: String) -> Date?
}

class ExpirationDateFormatter: ExpirationDateFormatting {

    enum CardExpireDateFormat {
        static let short = "MM/yy"
        static let long = "MM/yyyy"
    }

    // MARK: - Properties

    private let shortDateFormatter = DateFormatter()
    private let longFormatter = DateFormatter()

    // MARK: - Initializers

    init() {
        let locale = Locale.current
        let timeZone = TimeZone(secondsFromGMT: 0)

        shortDateFormatter.locale = locale
        shortDateFormatter.timeZone = timeZone
        shortDateFormatter.dateFormat = CardExpireDateFormat.short

        longFormatter.locale = locale
        longFormatter.timeZone = timeZone
        longFormatter.dateFormat = CardExpireDateFormat.long
    }

    // MARK: - ExpireDateFormatting

    func date(from string: String) -> Date? {
        // First, try the short ("MM/YY") format
        if let shortDate = shortDateFormatter.date(from: string) {
            return shortDate
        }

        // Then, try the long ("MM/YYYY") format
        return longFormatter.date(from: string)
    }
}
