//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package protocol ImageLoading {
    @discardableResult
    func load(url: URL, completion: @escaping ((UIImage?) -> Void)) -> AdyenCancellable
}

package final class ImageLoader: ImageLoading {

    internal let urlSession: URLSession
    
    /// Keeps loaded images in memory so that reloading them, for example in reused cells, does not flash an empty image.
    private let cache = NSCache<NSURL, UIImage>()
    
    public init(urlSession: URLSession = .init(configuration: .default)) {
        self.urlSession = urlSession
    }
    
    @discardableResult
    public func load(url: URL, completion: @escaping ((UIImage?) -> Void)) -> AdyenCancellable {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            completion(cachedImage)
            return AdyenTask {}
        }
        
        var urlSessionTask: URLSessionTask?
        let task = AdyenTask { urlSessionTask?.cancel() }
        
        urlSessionTask = urlSession.dataTask(with: url) { [weak self] data, _, _ in
            guard !task.isCancelled else { return }
            self?.handleImageResponse(url: url, data: data, completion: completion)
        }
        
        urlSessionTask?.resume()
        
        return task
    }
    
    private func handleImageResponse(url: URL, data: Data?, completion: @escaping ((UIImage?) -> Void)) {
        guard let data, let image = UIImage(data: data, scale: 1.0) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        cache.setObject(image, forKey: url as NSURL)
        
        DispatchQueue.main.async {
            completion(image)
        }
    }
}
