//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

protocol HasAPIClient {
    var apiClient: APIClientProtocol { get }
}

extension HasAPIClient  {

    public var apiClient: APIClientProtocol {
        guard let client = persistedApiClient else {
            let newClien = DefaultAPIClient()
            setPersistedApiCLient(newClien)
            return newClien
        }

        return client
    }

    private var persistedApiClient: DefaultAPIClient? {
        return objc_getAssociatedObject(self, &HasAPIClientKeys.persistedApiClient) as? DefaultAPIClient
    }

    private func setPersistedApiCLient(_ newClien: DefaultAPIClient) {
        objc_setAssociatedObject(self,
                                 &HasAPIClientKeys.persistedApiClient,
                                 newClien,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}

private enum HasAPIClientKeys {
    internal static var persistedApiClient = "persistedApiClient"
}
