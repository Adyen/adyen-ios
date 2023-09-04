//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// An image view that displays images from a remote location.
/// :nodoc:
open class NetworkImageView: UIImageView {
    
    /// The URL of the image to display.
    public var imageURL: URL? {
        didSet {
            cancelCurrentTask()
            image = placeholderImage
            
            // Only load an image when we're in a window.
            if let imageURL, window != nil {
                loadImage(from: imageURL)
            }
        }
    }
    
    /// The image to display before image loading starts and also in case it fails.
    public var placeholderImage: UIImage?
    
    /// :nodoc:
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        
        // If we have an image URL and are embedded in a window, load the image if we aren't already.
        if let imageURL, window != nil, dataTask == nil {
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - Private
    
    private var dataTask: URLSessionDataTask?
    
    private func loadImage(from url: URL) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            guard
                let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data, error == nil,
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
