//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking

internal protocol APIClientAware {
    var apiClient: APIClientProtocol { get }
    var palApiClient: APIClientProtocol { get }
}

// MARK: - Api Client

extension APIClientAware {

    var apiClient: APIClientProtocol {
        if let apiClient = getApiClient() {
            return apiClient
        }

        let apiClient = generateApiClient()
        setApiClient(apiClient)
        return apiClient
    }
    
    private func getApiClient() -> APIClientProtocol? {
        objc_getAssociatedObject(self, &AssociatedKeys.apiClient) as? APIClientProtocol
    }

    private func setApiClient(_ newValue: APIClientProtocol) {
        objc_setAssociatedObject(self, &AssociatedKeys.apiClient, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func generateApiClient() -> APIClientProtocol {
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
}

// MARK: - Pal Api Client

extension APIClientAware {
    
    var palApiClient: APIClientProtocol {
        if let apiClient = getPalApiClient() {
            return apiClient
        }

        let apiClient = generatePalApiClient()
        setPalApiClient(apiClient)
        return apiClient
    }
    
    private func getPalApiClient() -> APIClientProtocol? {
        objc_getAssociatedObject(self, &AssociatedKeys.palApiClient) as? APIClientProtocol
    }

    private func setPalApiClient(_ newValue: APIClientProtocol) {
        objc_setAssociatedObject(self, &AssociatedKeys.palApiClient, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func generatePalApiClient() -> APIClientProtocol {
        let context = DemoAPIContext(environment: ConfigurationConstants.classicAPIEnvironment)
        return DefaultAPIClient(apiContext: context)
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    internal static var apiClient = "apiClient"
    internal static var palApiClient = "palApiClient"
}
