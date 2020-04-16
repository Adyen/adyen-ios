//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol APIClientProtocol {
    
    typealias CompletionHandler<T> = (Result<T, Error>) -> Void
    
    func perform<R: Request>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>)
    
}

internal final class RetryAPIClient: APIClientProtocol {
    
    private let apiClient: APIClientProtocol
    
    private let maximumRetryCount: Int = 2
    
    internal init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    internal func perform<R>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        apiClient.perform(request) { [weak self] result in
            var request = request
            request.counter += 1
            self?.handle(result: result, for: request, completionHandler: completionHandler)
        }
    }
    
    internal func handle<R>(result: Result<R.ResponseType, Error>, for request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        switch result {
        case .success:
            completionHandler(result)
        case let .failure(error):
            if (error as NSError).code == -1005, request.counter < maximumRetryCount {
                /// Error code -1005 is caused by an http connection kept alive beyond its expiration time,
                /// while it was droped by the server.
                /// so all we have to do is retry to force creating a new connection.
                /// https://stackoverflow.com/questions/25372318/error-domain-nsurlerrordomain-code-1005-the-network-connection-was-lost
                perform(request, completionHandler: completionHandler)
            } else {
                completionHandler(.failure(error))
            }
        }
    }
    
}

internal final class APIClient: APIClientProtocol {
    
    internal typealias CompletionHandler<T> = (Result<T, Error>) -> Void
    
    internal let environment: DemoServerEnvironment
    
    internal init(environment: DemoServerEnvironment) {
        self.environment = environment
    }
    
    internal func perform<R: Request>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) {
        let url = environment.url.appendingPathComponent(request.path)
        let body: Data
        do {
            body = try Coder.encode(request)
        } catch {
            completionHandler(.failure(error))
            
            return
        }
        
        print(" ---- Request (/\(request.path)) ----")
        printAsJSON(body)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body
        
        urlRequest.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "x-demo-server-api-key": Configuration.demoServerAPIKey
        ]
        
        requestCounter += 1
        
        urlSession.adyen.dataTask(with: urlRequest) { [weak self] result in
            
            self?.requestCounter -= 1
            
            switch result {
            case let .success(data):
                print(" ---- Response (/\(request.path)) ----")
                printAsJSON(data)
                
                do {
                    let response = try Coder.decode(data) as R.ResponseType
                    completionHandler(.success(response))
                } catch {
                    completionHandler(.failure(error))
                }
            case let .failure(error):
                completionHandler(.failure(error))
            }
            
        }.resume()
    }
    
    private lazy var urlSession: URLSession = {
        URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
    }()
    
    private var requestCounter = 0 {
        didSet {
            let application = UIApplication.shared
            application.isNetworkActivityIndicatorVisible = self.requestCounter > 0
        }
    }
    
}

private func printAsJSON(_ data: Data) {
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        
        print(jsonString)
    } catch {
        if let string = String(data: data, encoding: .utf8) {
            print(string)
        }
    }
}
