//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct TelemetryData: Encodable {

    // MARK: - Properties

    internal var version: String? {
        Bundle(for: AnalyticsProvider.self).infoDictionary?["CFBundleShortVersionString"] as? String
    }

    internal let channel: String = "iOS"

    internal var locale: String {
        let languageCode = Locale.current.languageCode ?? ""
        let regionCode = Locale.current.regionCode ?? ""
        return "\(languageCode)_\(regionCode)"
    }

    internal let userAgent: String? = nil

    internal var deviceBrand: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }

    internal var systemVersion: String {
        UIDevice.current.systemVersion
    }

    internal var referrer: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    internal var screenWidth: Int {
        Int(UIScreen.main.bounds.width)
    }

    internal let containerWidth: Int? = nil

    internal let flavor: String

    internal var paymentMethods: [String] = []

    internal let component: String

    // MARK: - Initializers

    internal init(flavor: TelemetryFlavor) {
        self.flavor = flavor.value

        switch flavor {
        case let .dropIn(type, paymentMethods):
            self.paymentMethods = paymentMethods
            self.component = type
        case let .components(type):
            self.component = type
        default:
            self.component = ""
        }
    }
}
