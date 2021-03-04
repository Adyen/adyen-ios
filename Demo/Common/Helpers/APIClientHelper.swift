//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//


import Adyen

protocol APIClientAware {
    var apiClient: APIClientProtocol { get }
}

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
        if CommandLine.arguments.contains("-UITests") {
            guard
                let url = Bundle.main.url(forResource: "payment_methods_response", withExtension: "json"),
                let data = try? Data(contentsOf: url),
                let response = try? JSONDecoder().decode(PaymentMethodsResponse.self, from: data) else { return DefaultAPIClient() }

            let apiClient = APIClientMock()
            apiClient.mockedResults = [.success(response)]
            return apiClient
        }

        return DefaultAPIClient()
    }
}

private enum AssociatedKeys {
    internal static var apiClient = "apiClient"
}

