//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

public final class DebugAPIClient: APIClientProtocol {
    
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    public func perform<R>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        print(" ---- Request (/\(request.path)) ----")
        
        if let body: Data = try? Coder.encode(request) {
            printAsJSON(body)
        }
        
        apiClient.perform(request) { [weak self] result in
            var request = request
            request.counter += 1
            self?.handle(result: result, for: request, completionHandler: completionHandler)
        }
    }
    
    private func handle<R>(result: Result<R.ResponseType, Error>, for request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        switch result {
        case let .success(response):
//            print(" ---- Response (/\(request.path)) ----")
//            let string = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "&quot;", with: "\"")
//            let data = string!.data(using: .utf8)!
//            printAsJSON(data)
            completionHandler(result)
        case let .failure(error):
            completionHandler(.failure(error))
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
