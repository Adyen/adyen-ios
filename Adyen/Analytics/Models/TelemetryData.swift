//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

struct TelemetryData: Encodable {

    // MARK: - Properties

    let version: String = {
        adyenSdkVersion
    }()

    let channel: String = "iOS"

    var locale: String {
        let languageCode = Locale.current.languageCode ?? ""
        let regionCode = Locale.current.regionCode ?? ""
        return "\(languageCode)_\(regionCode)"
    }

    let userAgent: String? = nil

    let deviceBrand: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }()

    let systemVersion = UIDevice.current.systemVersion

    let referrer: String = Bundle.main.bundleIdentifier ?? ""

    var screenWidth: Int {
        Int(UIScreen.main.nativeBounds.width)
    }

    let containerWidth: Int? = nil

    let flavor: String

    var amount: Amount?
    
    var paymentMethods: [String] = []

    let component: String

    // MARK: - Initializers

    init(flavor: TelemetryFlavor, amount: Amount?) {
        self.flavor = flavor.value
        self.amount = amount

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
