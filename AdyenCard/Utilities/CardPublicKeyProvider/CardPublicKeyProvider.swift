//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal protocol AnyCardPublicKeyProvider: Component {
    
    /// :nodoc:
    typealias CompletionHandler = (Result<String, Error>) -> Void
    
    /// :nodoc:
    func fetch(completion: @escaping CompletionHandler)
}

/// :nodoc:
internal final class CardPublicKeyProvider: AnyCardPublicKeyProvider {
    
    /// :nodoc:
    internal let apiContext: APIContext
    
    /// :nodoc:
    internal static var cachedCardPublicKey: String?
    
    /// :nodoc:
    internal init(apiContext: APIContext,
                  apiClient: AnyRetryAPIClient? = nil) {
        self.apiContext = apiContext
        if let apiClient = apiClient {
            self.apiClient = apiClient
        }
    }
    
    /// :nodoc:
    internal func fetch(completion: @escaping CompletionHandler) {
        waitingList.append(completion)
        if let cardPublicKey = Self.cachedCardPublicKey {
            deliver(.success(cardPublicKey))
            return
        }
        
        guard waitingList.count == 1 else { return }
        
        let request = ClientKeyRequest(clientKey: apiContext.clientKey)
        
        apiClient.perform(request, shouldRetry: { [weak self] result in
            self?.shouldRetry(result) ?? false
        }, completionHandler: { [weak self] result in
            self?.handle(result)
        })
    }
    
    /// :nodoc:
    private lazy var apiClient: AnyRetryAPIClient = RetryAPIClient(apiClient: APIClient(apiContext: apiContext),
                                                                   scheduler: SimpleScheduler(maximumCount: 2))
    
    /// :nodoc:
    private var waitingList: [CompletionHandler] = []
    
    /// :nodoc:
    private func shouldRetry(_ result: Result<ClientKeyResponse, Swift.Error>) -> Bool {
        if case Result.success = result {
            return false
        }
        return true
    }
    
    /// :nodoc:
    private func handle(_ result: Result<ClientKeyResponse, Swift.Error>) {
        switch result {
        case let .success(response):
            Self.cachedCardPublicKey = response.cardPublicKey
            deliver(.success(response.cardPublicKey))
        case let .failure(error):
            deliver(.failure(error))
        }
    }
    
    /// :nodoc:
    private func deliver(_ result: Result<String, Swift.Error>) {
        waitingList.forEach {
            $0(result)
        }
        waitingList = []
    }
}
