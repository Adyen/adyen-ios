//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

public extension UIImageView {
    func downloadImage(from url: URL?) {
        image = nil
        
        guard let url = url else {
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data, scale: 1.0)
            else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
        task.resume()
    }
    
}
