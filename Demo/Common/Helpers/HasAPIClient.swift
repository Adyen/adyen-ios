//
//  HasAPIClient.swift
//  Adyen
//
//  Created by Vladimir Abramichev on 05/02/2021.
//  Copyright © 2021 Adyen. All rights reserved.
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
        get {
            return objc_getAssociatedObject(self, &HasAPIClientKeys.persistedApiClient) as? DefaultAPIClient
        }
    }

    private func setPersistedApiCLient(_ newClien: DefaultAPIClient) {
        objc_setAssociatedObject(self,
                                 &HasAPIClientKeys.persistedApiClient,
                                 newClien,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}

private struct HasAPIClientKeys {
    internal static var persistedApiClient = "persistedApiClient"
}
