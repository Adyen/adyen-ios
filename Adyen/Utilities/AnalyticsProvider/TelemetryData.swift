//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// 1. version (✅)
// 2. channel (✅)
// 3. locale (✅)
// 4. flavor (✅)
// 5. userAgent (null)
// 6. referrer (✅)
// 7. screenWidth (✅)
// 8. containerWidth (null)
// 9. component
// 10. checkoutAttemptId
internal struct TelemetryData {

    private enum Constants {
        static let channel = "iOS"
    }

    internal var version: String? {
        Bundle(for: AnalyticsProvider.self).infoDictionary?["CFBundleShortVersionString"] as? String
    }

    internal let channel: String = Constants.channel

    internal var locale: String {
        let languageCode = Locale.current.languageCode ?? ""
        let regionCode = Locale.current.regionCode ?? ""
        return "\(languageCode)_\(regionCode)"
    }

    internal let flavor: TelemetryFlavor

    internal let userAgent: String? = nil

    internal var referrer: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    internal var screenWidth: Int {
        Int(UIScreen.main.bounds.width)
    }

    internal let containerWidth: Int? = nil

    internal let paymentMethods: [String]

    internal let component: String
}
