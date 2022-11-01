//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal struct TelemetryData: Encodable {

    // MARK: - Properties

    internal let version: String? = {
        Bundle(for: AnalyticsProvider.self).infoDictionary?["CFBundleShortVersionString"] as? String
    }()

    internal let channel: String = "iOS"

    internal var locale: String {
        let languageCode = Locale.current.languageCode ?? ""
        let regionCode = Locale.current.regionCode ?? ""
        return "\(languageCode)_\(regionCode)"
    }

    internal let userAgent: String? = nil

    internal let deviceBrand: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }()

    internal let systemVersion = UIDevice.current.systemVersion

    internal let referrer: String = Bundle.main.bundleIdentifier ?? ""

    internal var screenWidth: Int {
        Int(UIScreen.main.nativeBounds.width)
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
            self.component = type.rawValue
        default:
            self.component = ""
        }
    }
}
