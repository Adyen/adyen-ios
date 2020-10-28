//
// Copyright (c) 2020 Adyen N.V.
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
    func fetch(completion: @escaping CompletionHandler) throws
}

/// :nodoc:
internal class CardPublicKeyProvider: AnyCardPublicKeyProvider {
    
    /// :nodoc:
    internal static var cachedCardPublicKey: String?
    
    /// :nodoc:
    internal init(apiClient: AnyRetryAPIClient? = nil) {
        if let apiClient = apiClient {
            self.apiClient = apiClient
        }
    }
    
    /// :nodoc:
    internal init(cardPublicKey: String) {
        Self.cachedCardPublicKey = cardPublicKey
    }
    
    /// :nodoc:
    internal func fetch(completion: @escaping CompletionHandler) throws {
        waitingList.append(completion)
        if let cardPublicKey = Self.cachedCardPublicKey {
            deliver(.success(cardPublicKey))
            return
        }
        
        guard let clientKey = clientKey else {
            throw CardComponent.Error.missingClientKey
        }
        
        guard waitingList.count == 1 else { return }
        
        let request = ClientKeyRequest(clientKey: clientKey)
        
        apiClient.perform(request, shouldRetry: { [weak self] result in
            self?.shouldRetry(result) ?? false
        }, completionHandler: { [weak self] result in
            self?.handle(result)
        })
    }
    
    /// :nodoc:
    private lazy var apiClient: AnyRetryAPIClient = RetryAPIClient(apiClient: APIClient(environment: environment),
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
