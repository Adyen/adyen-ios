//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation
    
/// :nodoc:
/// Struct that defines the environment to retrieve resources from.
public struct Environment: AnyAPIEnvironment {
    
    /// :nodoc:
    public var baseURL: URL

    /// :nodoc:
    /// Adyen's test environment.
    public static let test = Environment(baseURL: URL(string: "https://checkoutshopper-test.adyen.com/")!)

    /// :nodoc:
    public static let beta = Environment(baseURL: URL(string: "https://checkoutshopper-beta.adyen.com/")!)
    
    /// :nodoc:
    /// Adyen's default live environment.
    public static let live = Environment(baseURL: URL(string: "https://checkoutshopper-live.adyen.com/")!)
    
    /// :nodoc:
    /// Adyen's European live environment.
    public static let liveEurope = Environment.live
    
    /// :nodoc:
    /// Adyen's Australian live environment.
    public static let liveAustralia = Environment(baseURL: URL(string: "https://checkoutshopper-live-au.adyen.com/")!)
    
    /// :nodoc:
    /// Adyen's United States live environment.
    public static let liveUnitedStates = Environment(baseURL: URL(string: "https://checkoutshopper-live-us.adyen.com/")!)

    /// Adyen's India live  environment.
    public static let liveIndia = Environment(baseURL: URL(string: "https://checkoutshopper-live-in.adyen.com/")!)

    /// Initializes an `Environment` object.
    ///
    /// - Parameters:
    ///   - baseURL: The environment base url.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

}
