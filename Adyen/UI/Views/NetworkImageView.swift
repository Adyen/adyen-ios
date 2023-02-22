//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// An image view that displays images from a remote location.
@_spi(AdyenInternal)
open class NetworkImageView: UIImageView {
    
    private static var session = {
        var configuration = URLSessionConfiguration.default
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
        if let imageURL = imageURL, window != nil, dataTask == nil {
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - Private
    
    private var dataTask: URLSessionDataTask?
    
    private func loadImage(from url: URL) {
        let task = NetworkImageView.session.dataTask(with: url) { data, response, error in
            guard
                let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data, scale: 1.0)
            else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
                self.dataTask = nil
            }
        }
        task.resume()
        
        dataTask = task
    }
    
    private func cancelCurrentTask() {
        dataTask?.cancel()
        dataTask = nil
    }
    
}
