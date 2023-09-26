//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking

enum ApiClientHelper {
    
    static func generateApiClient() -> APIClientProtocol {
        guard CommandLine.arguments.contains("-UITests"),
              let paymentMethodsUrl = Bundle.main.url(forResource: "payment_methods_response", withExtension: "json"),
              let sessionsUrl = Bundle.main.url(forResource: "session_response", withExtension: "json"),
              let paymentMethodsData = try? Data(contentsOf: paymentMethodsUrl),
              let sessionData = try? Data(contentsOf: sessionsUrl),
              let paymentMethodsResponse = try? JSONDecoder().decode(PaymentMethodsResponse.self, from: paymentMethodsData),
              let sessionResponse = try? JSONDecoder().decode(SessionResponse.self, from: sessionData)
        else { return DefaultAPIClient() }
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(paymentMethodsResponse), .success(sessionResponse)]
        return apiClient
    }
    
    static func generatePalApiClient() -> APIClientProtocol {
        let context = DemoAPIContext(environment: ConfigurationConstants.classicAPIEnvironment)
        return DefaultAPIClient(apiContext: context)
    }
}
