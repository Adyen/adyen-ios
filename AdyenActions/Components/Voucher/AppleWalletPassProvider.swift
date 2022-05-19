//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

internal protocol AnyAppleWalletPassProvider {

    typealias CompletionHandler = (Result<Data, Error>) -> Void

    func provide(with passToken: String, completion: @escaping CompletionHandler)
}

internal final class AppleWalletPassProvider: AnyAppleWalletPassProvider,
    APIContextAware {
    
    internal let apiContext: APIContext
    
    internal convenience init(apiContext: APIContext) {
        self.init(apiContext: apiContext, apiClient: nil)
    }
    
    internal init(apiContext: APIContext, apiClient: AnyRetryAPIClient? = nil) {
        self.apiContext = apiContext
        if let apiClient = apiClient {
            self.retryApiClient = apiClient
        } else {
            let scheduler = SimpleScheduler(maximumCount: 2)
            self.retryApiClient = APIClient(apiContext: apiContext)
                .retryAPIClient(with: scheduler)
        }
    }

    internal func provide(with passToken: String, completion: @escaping CompletionHandler) {
        let request = AppleWalletPassRequest(passToken: passToken)
        apiClient.perform(request) { [weak self] result in
            self?.handle(result, completion: completion)
        }
    }
    
    // MARK: - Private
    
    private lazy var apiClient: UniqueAssetAPIClient<AppleWalletPassResponse> = {
        let retryOnErrorApiClient = retryApiClient.retryOnErrorAPIClient()
        return UniqueAssetAPIClient<AppleWalletPassResponse>(apiClient: retryOnErrorApiClient)
    }()

    private let retryApiClient: AnyRetryAPIClient

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
