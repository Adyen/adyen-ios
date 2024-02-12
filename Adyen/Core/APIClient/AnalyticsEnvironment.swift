//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Enum that defines the  analytics environment URLs..
@_spi(AdyenInternal)
public enum AnalyticsEnvironment: String, AnyAPIEnvironment {
    
    case test = "https://checkoutanalytics-test.adyen.com/"
    
    case liveEurope = "https://checkoutanalytics-live.adyen.com/"
    
    case liveAustralia = "https://checkoutanalytics-live-au.adyen.com/"
    
    case liveUnitedStates = "https://checkoutanalytics-live-us.adyen.com/"
    
    case liveApse = "https://checkoutanalytics-live-apse.adyen.com/"
    
    case liveIndia = "https://checkoutanalytics-live-in.adyen.com/"
    
    @_spi(AdyenInternal)
    case beta = "https://beta.adyen.com/checkoutanalytics/v3/analytics/"
    
    @_spi(AdyenInternal)
    case local = "http://localhost:8080/"
    
    public var baseURL: URL { URL(string: rawValue)! }
    
}

extension Environment {
    
    internal func toAnalyticsEnvironment() -> AnalyticsEnvironment {
        switch self {
        case .beta:
            return .beta
        case .test:
            return .test
        case .liveApse:
            return .liveApse
        case .liveIndia:
            return .liveIndia
        case .liveEurope:
            return .liveEurope
        case .liveAustralia:
            return .liveAustralia
        case .liveUnitedStates:
            return .liveUnitedStates
        case .local:
            return .local
        default:
            return .test
        }
    }
}
