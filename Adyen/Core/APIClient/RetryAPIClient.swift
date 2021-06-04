//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// An API Client that enables retying request on the basis of a closure.
public protocol AnyRetryAPIClient: APIClientProtocol {
    
    /// :nodoc:
    typealias ShouldRetryHandler<T> = (_ result: Result<T, Error>) -> Bool
    
    /// :nodoc:
    /// Performs the API request, and takes a closure to decide whether to repeat the request.
    func perform<R>(_ request: R, shouldRetry: ShouldRetryHandler<R.ResponseType>?, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request
}

/// :nodoc:
extension AnyRetryAPIClient {

    /// :nodoc:
    public func retryOnErrorAPIClient() -> APIClientProtocol {
        RetryOnErrorAPIClient(apiClient: self)
    }
}

/// :nodoc:
/// An API Client that enables retying request on the basis of a closure or a retry count.
public final class RetryAPIClient: AnyRetryAPIClient {
    
    /// :nodoc:
    private let apiClient: APIClientProtocol
    
    /// :nodoc:
    /// Scheduler of retries.
    private let scheduler: Scheduler
    
    /// :nodoc:
    /// Initializes the API client.
    ///
    /// - Parameters:
    ///   - apiClient: The wrapped API client.
    ///   - scheduler: The Scheduler of retries.
    public init(apiClient: APIClientProtocol, scheduler: Scheduler) {
        self.apiClient = apiClient
        self.scheduler = scheduler
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
        if let shouldRetry = shouldRetry, shouldRetry(result) {
            retry(request, result: result, shouldRetry: shouldRetry, completionHandler: completionHandler)
        } else {
            completionHandler(result)
        }
    }
    
    private func retry<R>(_ request: R, result: Result<R.ResponseType, Error>, shouldRetry: ShouldRetryHandler<R.ResponseType>?, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        let isDone = schedule(request.counter) { [weak self] in
            self?.perform(request, shouldRetry: shouldRetry, completionHandler: completionHandler)
        }
        if isDone {
            completionHandler(result)
        }
    }
    
    private func schedule(_ currentCount: UInt, closure: @escaping () -> Void) -> Bool {
        scheduler.schedule(currentCount, closure: closure)
    }
    
}
