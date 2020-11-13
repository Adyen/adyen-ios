//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Struct that defines the environment to retrieve resources from.
public struct Environment: APIEnvironment {
    
    /// :nodoc:
    public var baseURL: URL
    
    /// :nodoc:
    public var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]

        if let clientKey = clientKey {
            headers["x-client-key"] = clientKey
        } else {
            assertionFailure("Client key is missing.")
        }
        return headers
    }
    
    /// :nodoc:
    public var queryParameters: [URLQueryItem] = []
    
    /// :nodoc:
    public var clientKey: String?

    /// Adyen's local environment.
    /// :nodoc:
    public static let local = Environment(baseURL: URL(string: "http://localhost:8080/")!)

    /// Adyen's test environment.
    public static let test = Environment(baseURL: URL(string: "https://checkoutshopper-test.adyen.com/")!)
    
    /// Adyen's default live environment.
    public static let live = Environment(baseURL: Environment.defaultLiveBaseURL)
    
    /// Adyen's European live environment.
    public static let liveEurope = Environment.live
    
    /// Adyen's Australian live environment.
    public static let liveAustralia = Environment(baseURL: URL(string: "https://checkoutshopper-live-au.adyen.com/")!)
    
    /// Adyen's United States live environment.
    public static let liveUnitedStates = Environment(baseURL: URL(string: "https://checkoutshopper-live-us.adyen.com/")!)

    public init(baseURL: URL? = nil) {
        self.baseURL = baseURL ?? Environment.defaultLiveBaseURL
    }
    
    // MARK: - Private
    
    private static let defaultLiveBaseURL = URL(string: "https://checkoutshopper-live.adyen.com/")!
}
