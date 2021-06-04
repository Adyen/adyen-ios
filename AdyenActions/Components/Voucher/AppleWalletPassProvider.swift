//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol AnyAppleWalletPassProvider {
    typealias CompletionHandler = (Result<Data, Error>) -> Void

    func provide(with passToken: String, completion: @escaping CompletionHandler)
}

internal final class AppleWalletPassProvider: AnyAppleWalletPassProvider,
    APIContextAware {
    internal let apiContext: APIContext
    
    internal init(apiContext: APIContext) {
        self.apiContext = apiContext
    }
    
    /// :nodoc:
    internal init(apiContext: APIContext, apiClient: AnyRetryAPIClient? = nil) {
        self.apiContext = apiContext
        if let apiClient = apiClient {
            self.retryApiClient = apiClient
        }
    }

    private lazy var apiClient: UniqueAssetAPIClient<AppleWalletPassResponse> = {
        UniqueAssetAPIClient<AppleWalletPassResponse>(apiClient: retryApiClient.retryOnErrorAPIClient())
    }()

    private lazy var retryApiClient: AnyRetryAPIClient = {
        let scheduler = SimpleScheduler(maximumCount: 2)
        return APIClient(apiContext: apiContext).retryAPIClient(with: scheduler)
    }()

    internal func provide(with passToken: String, completion: @escaping CompletionHandler) {
        let request = AppleWalletPassRequest(passToken: passToken)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }

    private func handle(_ result: Result<AppleWalletPassResponse, Swift.Error>,
                        completion: @escaping CompletionHandler) {
        switch result {
        case let .success(response):
            completion(.success(response.passData))
        case let .failure(error):
            completion(.failure(error))
        }
    }
}
