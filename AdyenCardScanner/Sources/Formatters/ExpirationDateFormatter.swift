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

    // MARK: - Supported Formats

    private enum ExpirationDateFormat: CaseIterable {
        case shortSlash
        case longSlash
        case shortDash
        case longDash

        var pattern: String {
            switch self {
            case .shortSlash: return "MM/yy"
            case .longSlash: return "MM/yyyy"
            case .shortDash: return "MM-yy"
            case .longDash: return "MM-yyyy"
            }
        }
    }

    // MARK: - Properties

    private let formatter: DateFormatter

    // MARK: - Initializer

    internal init() {
        formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
    }

    // MARK: - ExpirationDateFormatting

    internal func date(from string: String) -> Date? {
        for format in ExpirationDateFormat.allCases {
            formatter.dateFormat = format.pattern
            if let date = formatter.date(from: string) {
                return date
            }
        }

        // No format matched
        return nil
    }
}
