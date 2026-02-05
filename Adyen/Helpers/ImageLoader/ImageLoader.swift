//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public protocol ImageLoading {
    @discardableResult
    func load(url: URL, completion: @escaping ((UIImage?) -> Void)) -> AdyenCancellable
}

@_spi(AdyenInternal)
public final class ImageLoader: ImageLoading {
    
    internal let urlSession: URLSession
    
    public init(urlSession: URLSession = .init(configuration: .default)) {
        self.urlSession = urlSession
    }
    
    @discardableResult
    public func load(url: URL, completion: @escaping ((UIImage?) -> Void)) -> AdyenCancellable {
        var urlSessionTask: URLSessionTask?
        let task = AdyenTask { urlSessionTask?.cancel() }
        
        urlSessionTask = urlSession.dataTask(with: url) { [weak self] data, _, _ in
            guard !task.isCancelled else { return }
            self?.handleImageResponse(data: data, completion: completion)
        }
        
        urlSessionTask?.resume()
        
        return task
    }
    
    private func handleImageResponse(data: Data?, completion: @escaping ((UIImage?) -> Void)) {
        guard let data, let image = UIImage(data: data, scale: 1.0) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        DispatchQueue.main.async {
            completion(image)
        }
    }
}
