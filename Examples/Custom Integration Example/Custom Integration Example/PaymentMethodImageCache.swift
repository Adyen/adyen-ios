//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class PaymentMethodImageCache: NSCache<AnyObject, AnyObject> {
    
    // MARK: - Public
    
    static let shared = PaymentMethodImageCache()
    
    func cellIcon(from url: URL) -> UIImage? {
        let key = cellKey(from: url)
        return object(forKey: key) as? UIImage? ?? nil
        
    }
    
    func confirmationIcon(from url: URL) -> UIImage? {
        let key = confirmationKey(from: url)
        return object(forKey: key) as? UIImage? ?? nil
    }
    
    func retrieveCellIcon(from url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        let key = cellKey(from: url)
        getImage(from: url, key: key, completionHandler: completionHandler)
    }
    
    func retrieveConfirmationIcon(from url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        let key = confirmationKey(from: url)
        getImage(from: url, key: key, completionHandler: completionHandler)
    }
    
    // MARK: - Private
    
    private func cellKey(from url: URL) -> NSString {
        return "\(url.path)-cell" as NSString
    }
    
    private func confirmationKey(from url: URL) -> NSString {
        return "\(url.path)-confirmation" as NSString
    }
    
    private func getImage(from url: URL, key: NSString, completionHandler: @escaping (UIImage?) -> Void) {
        if let image = self.object(forKey: key) as? UIImage {
            completionHandler(image)
        } else {
            fetchImage(from: url, completionHandler: {
                let image = self.object(forKey: key) as? UIImage? ?? nil
                DispatchQueue.main.async {
                    completionHandler(image)
                }
            })
        }
    }
    
    private func fetchImage(from url: URL, completionHandler: @escaping () -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
            if let data = data, error == nil {
                if let rawImage = UIImage(data: data) {
                    if let cellImage = self.cellImage(from: rawImage) {
                        self.setObject(cellImage, forKey: self.cellKey(from: url))
                    }
                    if let confirmationImage = self.confirmationImage(from: rawImage) {
                        self.setObject(confirmationImage, forKey: self.confirmationKey(from: url))
                    }
                }
            }
            completionHandler()
        }).resume()
    }
    
    private func cellImage(from image: UIImage) -> UIImage? {
        let imageWidth: CGFloat = 40.0
        return scaled(image, width: imageWidth)
    }
    
    private func confirmationImage(from image: UIImage) -> UIImage? {
        let imageWidth: CGFloat = 30.0
        return scaled(image, width: imageWidth)
    }
    
    private func scaled(_ image: UIImage, width: CGFloat) -> UIImage? {
        let scale = width / image.size.width
        let newHeight = image.size.height * scale
        let newImageSize = CGSize(width: width, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: newHeight))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
}
