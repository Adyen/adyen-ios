//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Struct that defines the environment to retrieve resources from.
public struct Environment: AnyAPIEnvironment {
    
    public var baseURL: URL

    /// Adyen's test environment.
    public static let test = Environment(baseURL: URL(string: "https://checkoutshopper-test.adyen.com/")!)
    
    @_spi(AdyenInternal)
    public static let beta = Environment(baseURL: URL(string: "https://checkoutshopper-beta.adyen.com/")!)
    
    @_spi(AdyenInternal)
    public static let local = Environment(baseURL: URL(string: "http://localhost:8080/")!)

    /// Adyen's default live environment.
    @available(*, deprecated, message:
        """
        This property is no longer supported.
        Please explicitly select the environment matching your region.
        """)
    public static let live = liveEurope

    /// Adyen's European live environment.
    public static let liveEurope = Environment(baseURL: URL(string: "https://checkoutshopper-live.adyen.com/")!)

    /// Adyen's Australian live environment.
    public static let liveAustralia = Environment(baseURL: URL(string: "https://checkoutshopper-live-au.adyen.com/")!)

    /// Adyen's United States live environment.
    public static let liveUnitedStates = Environment(baseURL: URL(string: "https://checkoutshopper-live-us.adyen.com/")!)

    /// Adyen's apse live  environment.
    public static let liveApse = Environment(baseURL: URL(string: "https://checkoutshopper-live-apse.adyen.com/")!)

    /// Adyen's India live  environment.
    public static let liveIndia = Environment(baseURL: URL(string: "https://checkoutshopper-live-in.adyen.com/")!)

    /// Initializes an `Environment` object.
    ///
    /// - Parameters:
    ///   - baseURL: The environment base url.
    internal init(baseURL: URL) {
        self.baseURL = baseURL
    }

}
