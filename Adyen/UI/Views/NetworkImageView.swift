//
// Copyright (c) 2020 Adyen N.V.
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
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        
        // If we have an image URL and are embedded in a window, load the image if we aren't already.
        if let imageURL = imageURL, window != nil, dataTask == nil {
            loadImage(from: imageURL)
        }
    }
    
    // MARK: - Private

    private let brandProtectedImages: [String: String] = ["applepay": "brand_apple_pay"]
    
    private var dataTask: URLSessionDataTask?
    
    private func setImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.image = image
            self.dataTask = nil
        }
    }

    private func loadImage(from url: URL) {
        let parts = url.lastPathComponent.split(separator: "@")
        if parts.count > 1,
           let internalName = brandProtectedImages[String(parts[0])],
           let image = UIImage(named: internalName, in: Bundle.coreInternalResources, compatibleWith: nil) {
            return setImage(image)
        }

        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            guard
                let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data, scale: 1.0)
            else {
                return
            }
            
            self.setImage(image)
        }
        task.resume()
        
        dataTask = task
    }
    
    private func cancelCurrentTask() {
        dataTask?.cancel()
        dataTask = nil
    }
    
}
