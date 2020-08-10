//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An API Client that enables retying request on the basis of a closure.
public protocol AnyRetryAPIClient: APIClientProtocol {
    
    typealias ShouldRetryHandler<T> = (_ result: Result<T, Error>) -> Bool
    
    /// Performs the API request, and takes a closure to decide whether to repeat the request.
    func perform<R>(_ request: R, shouldRetry: ShouldRetryHandler<R.ResponseType>?, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request
}

/// An API Client that enables retying request on the basis of a closure or a retry count.
public final class RetryAPIClient: AnyRetryAPIClient {
    
    /// :nodoc:
    private let apiClient: APIClientProtocol
    
    /// The maximum number of times to retry in case of error, doesn't apply if the `ShouldRetryHandler` is supplied.
    private let maximumRetryCount: Int
    
    /// Initializes the API client.
    ///
    /// - Parameters:
    ///   - apiClient: The wrapped API client.
    ///   - maximumRetryCount: The maximum number of times to retry in case of error, doesn't apply if the `ShouldRetryHandler` is supplied.
    public init(apiClient: APIClientProtocol, maximumRetryCount: Int = 0) {
        self.apiClient = apiClient
        self.maximumRetryCount = maximumRetryCount
    }
    
    /// :nodoc:
    public func perform<R>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        perform(request, shouldRetry: nil, completionHandler: completionHandler)
    }
    
    /// :nodoc:
    public func perform<R>(_ request: R, shouldRetry: ShouldRetryHandler<R.ResponseType>?, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        apiClient.perform(request) { [weak self] result in
            var request = request
            request.counter += 1
            
            self?.handle(result: result, for: request, shouldRetry: shouldRetry, completionHandler: completionHandler)
        }
    }
    
    /// :nodoc:
    private func handle<R>(result: Result<R.ResponseType, Error>, for request: R, shouldRetry: ShouldRetryHandler<R.ResponseType>?, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        if let shouldRetry = shouldRetry {
            if shouldRetry(result) {
                perform(request, shouldRetry: shouldRetry, completionHandler: completionHandler)
            } else {
                completionHandler(result)
            }
        } else if case Result.failure = result, request.counter < maximumRetryCount {
            perform(request, completionHandler: completionHandler)
        } else {
            completionHandler(result)
        }
    }
    
}
