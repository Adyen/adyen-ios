//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

///// An image view that displays images from a remote location.
// @_spi(AdyenInternal)
// open class NetworkImageView: UIImageView {
//
//    private var dataTask: URLSessionDataTask?
//
//    private enum Constants {
//        internal static let minutes10: TimeInterval = 600
//    }
//
//    private lazy var session: URLSession = {
//        let configuration = URLSessionConfiguration.default
//        configuration.requestCachePolicy = .reloadRevalidatingCacheData
//        return URLSession(configuration: configuration)
//    }()
//
//    /// The URL of the image to display.
//    public var imageURL: URL? {
//        didSet {
//            cancelCurrentTask()
//            image = placeholderImage
//
//            // Only load an image when we're in a window.
//            if let imageURL, window != nil {
//                loadImage(from: imageURL)
//            }
//        }
//    }
//
//    /// The image to display before image loading starts and also in case it fails.
//    public var placeholderImage: UIImage?
//
//    override open func didMoveToWindow() {
//        super.didMoveToWindow()
//
//        // If we have an image URL and are embedded in a window, load the image if we aren't already.
//        if let imageURL, window != nil, dataTask == nil {
//            loadImage(from: imageURL)
//        }
//    }
//
//    // MARK: - Private
//
//    private func setImage(_ image: UIImage) {
//        DispatchQueue.main.async {
//            self.image = image
//            self.dataTask = nil
//        }
//    }
//
//    private func loadImage(from url: URL) {
//        let urlRequest = URLRequest(url: url,
//                                    cachePolicy: .useProtocolCachePolicy,
//                                    timeoutInterval: Constants.minutes10)
//        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
//            guard
//                let response = response as? HTTPURLResponse,
//                response.statusCode == 200,
//                error == nil,
//                let data,
//                let image = UIImage(data: data, scale: 1.0)
//            else {
//                return
//            }
//
//            self?.setImage(image)
//        }
//        task.resume()
//
//        dataTask = task
//    }
//
//    private func cancelCurrentTask() {
//        dataTask?.cancel()
//        dataTask = nil
//    }
//
// }
