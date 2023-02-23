//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// An image view that displays images from a remote location.
@_spi(AdyenInternal)
open class NetworkImageView: UIImageView {

    private enum Constants {
        internal static let bytes10Mb: Int = 10_000_000
        internal static let bytes1Gb: Int = 1_000_000_000
        internal static let folderName = "AdyenIcons"
        internal static let minutes10: TimeInterval = 600
    }

    private static var cache: URLCache = {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent(Constants.folderName)
        if #available(iOS 13.0, *) {
            let cache = URLCache(memoryCapacity: Constants.bytes10Mb ,
                                 diskCapacity: Constants.bytes1Gb,
                                 directory: diskCacheURL)
            cache.removeAllCachedResponses()
            return cache
        } else {
            return URLCache.shared
        }
    }()

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadRevalidatingCacheData
        configuration.urlCache = NetworkImageView.cache
        return URLSession(configuration: configuration)
    }()
    
    /// The URL of the image to display.
    public var imageURL: URL? {
        didSet {
            cancelCurrentTask()
            image = placeholderImage
            
            // Only load an image when we're in a window.
            if let imageURL = imageURL, window != nil {
                loadImage(from: imageURL)
            }
        }
    }
    
    /// The image to display before image loading starts and also in case it fails.
    public var placeholderImage: UIImage?
    
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        
        // If we have an image URL and are embedded in a window, load the image if we aren't already.
        if let imageURL = imageURL, window != nil, downloadTask == nil {
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - Private
    
    private var downloadTask: URLSessionDownloadTask?
    
    fileprivate func setImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.image = image
            self.downloadTask = nil
        }
    }

    private func loadImage(from url: URL) {
        let urlRequest = URLRequest(url: url,
                                    cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: Constants.minutes10)
        if let cachedResponse = NetworkImageView.cache.cachedResponse(for: urlRequest),
           let image = UIImage(data: cachedResponse.data, scale: 1.0) {
            return setImage(image)
        }

        let task = session.downloadTask(with: urlRequest) { [weak self] url, response, error in
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                error == nil,
                let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data, scale: 1.0)
            else {
                return
            }

            NetworkImageView.cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: urlRequest)
            self?.setImage(image)
        }
        task.resume()
        
        downloadTask = task
    }
    
    private func cancelCurrentTask() {
        downloadTask?.cancel()
        downloadTask = nil
    }
    
}
