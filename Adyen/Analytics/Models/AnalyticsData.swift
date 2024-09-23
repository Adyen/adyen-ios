//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// The context in which the SDK operates
///
/// Used to e.g. override the version + platform from within the Flutter SDK
@_spi(AdyenInternal)
public struct AnalyticsContext {
    
    internal let version: String
    internal let platform: Platform
    
    public init(
        version: String = adyenSdkVersion,
        platform: Platform = .iOS
    ) {
        self.version = version
        self.platform = platform
    }
}

@_spi(AdyenInternal)
public extension AnalyticsContext {

    enum Platform: String {
        case iOS = "iOS"
        case reactNative = "react-native"
        case flutter
    }
}

internal struct AnalyticsData: Encodable {

    // MARK: - Properties

    /// The version of the SDK
    internal let version: String

    internal let channel: String = "iOS"
    
    /// The platform the SDK is running on (e.g. ios, flutter, react-native)
    internal let platform: String

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
    
    internal let deviceModel = UIDevice.current.model

    internal let systemVersion = UIDevice.current.systemVersion

    internal let referrer: String = Bundle.main.bundleIdentifier ?? ""

    internal var screenWidth: Int {
        Int(UIScreen.main.nativeBounds.width)
    }

    internal let containerWidth: Int? = nil

    internal let flavor: String

    internal var amount: Amount?
    
    internal var sessionId: String?
    
    internal var paymentMethods: [String] = []

    internal let component: String

    // MARK: - Initializers

    internal init(
        flavor: AnalyticsFlavor,
        additionalFields: AdditionalAnalyticsFields?,
        context: AnalyticsContext
    ) {
        self.flavor = flavor.value
        self.amount = additionalFields?.amount
        self.sessionId = additionalFields?.sessionId
        
        self.version = context.version
        self.platform = context.platform.rawValue

        switch flavor {
        case let .dropIn(type, paymentMethods):
            self.paymentMethods = paymentMethods
            self.component = type
        case let .components(type):
            self.component = type.rawValue
        }
    }
}
