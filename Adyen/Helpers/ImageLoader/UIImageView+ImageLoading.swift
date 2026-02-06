//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public extension UIImageView {
    @discardableResult
    func load(
        url: URL,
        using imageLoader: ImageLoading,
        placeholder: UIImage? = nil
    ) -> AdyenCancellable {
        
        if let placeholder {
            self.image = placeholder
        }
        
        return imageLoader.load(url: url) { [weak self] image in
            self?.image = image ?? placeholder
        }
    }
}
