//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking

internal enum ApiClientHelper {
    
    internal static func generateApiClient() -> APIClientProtocol {
        guard CommandLine.arguments.contains("-UITests"),
              let paymentMethodsUrl = Bundle.main.url(forResource: "payment_methods_response", withExtension: "json"),
              let sessionsUrl = Bundle.main.url(forResource: "session_response", withExtension: "json"),
              let paymentMethodsData = try? Data(contentsOf: paymentMethodsUrl),
              let sessionData = try? Data(contentsOf: sessionsUrl),
              let paymentMethodsResponse = try? JSONDecoder().decode(PaymentMethodsResponse.self, from: paymentMethodsData),
              let sessionResponse = try? JSONDecoder().decode(SessionResponse.self, from: sessionData)
        else { return DefaultAPIClient() }
        
        let apiClient = DemoAPIClientMock()
        apiClient.mockedResults = [.success(paymentMethodsResponse), .success(sessionResponse)]
        return apiClient
    }
    
    /// Returns an API client that exposes the async `perform` API.
    /// Used by examples that have been migrated to the new async callback structure.
    /// Note: Skips the `RetryAPIClient` wrapper and UI-test mock path; these can be
    /// re-added once the async path gains broader adoption.
    internal static func generateAsyncApiClient() -> AsyncAPIClientProtocol {
        APIClient(apiContext: DemoAPIContext())
    }
}
