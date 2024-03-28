//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

internal struct AnalyticsRequest: APIRequest {
    
    internal typealias ResponseType = EmptyResponse

    internal let path: String
    
    internal var counter: UInt = 0
    
    internal let headers: [String: String] = [:]

    internal let queryParameters: [URLQueryItem] = []

    internal let method: HTTPMethod = .post
    
    internal var channel: String = "iOS"
    
    internal var platform: String
    
    internal var infos: [AnalyticsEventInfo] = []
    
    internal var logs: [AnalyticsEventLog] = []
    
    internal var errors: [AnalyticsEventError] = []
    
    internal init(checkoutAttemptId: String, platform: String) {
        self.path = "checkoutanalytics/v3/analytics/\(checkoutAttemptId)"
        self.platform = platform
    }
    
    private enum CodingKeys: String, CodingKey {
        case channel
        case platform
        case infos = "info"
        case logs
        case errors
        
    }
}
