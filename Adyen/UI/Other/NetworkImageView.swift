//
// Copyright (c) 2019 Adyen B.V.
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
            image = nil
            
            // Only load an image when we're in a window.
            if let imageURL = imageURL, window != nil {
                loadImage(from: imageURL)
            }
        }
    }
    
    /// :nodoc:
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        
        // If we have an image URL and are embedded in a window, load the image if we aren't already.
        if let imageURL = imageURL, window != nil, dataTask == nil {
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - Private
    
    private var dataTask: URLSessionDataTask?
    
    public func loadImage(from url: URL) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
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
