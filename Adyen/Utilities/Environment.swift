//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Struct that defines the environment to retrieve resources from.
public struct Environment {
    
    /// Adyen's test environment.
    public static let test = Environment(baseURL: URL(string: "https://checkoutshopper-test.adyen.com/")!,
                                         cardPublicKeyBaseURL: URL(string: "https://test.adyen.com/")!)
    
    /// Adyen's default live environment.
    public static let live = Environment(baseURL: Environment.defaultLiveBaseURL,
                                         cardPublicKeyBaseURL: Environment.defaultLiveCardPublicKeyBaseURL)
    
    /// Adyen's European live environment.
    public static let liveEurope = Environment.live
    
    /// Adyen's Australian live environment.
    public static let liveAustralia = Environment(baseURL: URL(string: "https://checkoutshopper-live-au.adyen.com/")!,
                                                  cardPublicKeyBaseURL: URL(string: "https://live-au.adyen.com/")!)
    
    /// Adyen's United States live environment.
    public static let liveUnitedStates = Environment(baseURL: URL(string: "https://checkoutshopper-live-us.adyen.com/")!,
                                                     cardPublicKeyBaseURL: URL(string: "https://live-us.adyen.com/")!)
    
    /// Base URL for the logos.
    public var baseURL: URL
    
    /// Base URL for fetching a card public key with token.
    public var cardPublicKeyBaseURL: URL
    
    public init(baseURL: URL? = nil, cardPublicKeyBaseURL: URL? = nil) {
        self.baseURL = baseURL ?? Environment.defaultLiveBaseURL
        self.cardPublicKeyBaseURL = cardPublicKeyBaseURL ?? Environment.defaultLiveCardPublicKeyBaseURL
    }
    
    // MARK: - Private
    
    private static let defaultLiveBaseURL = URL(string: "https://checkoutshopper-live.adyen.com/")!
    private static let defaultLiveCardPublicKeyBaseURL = URL(string: "https://live.adyen.com/")!
}
