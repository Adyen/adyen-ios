//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public extension UIImageView {
    @discardableResult
    func load(url: URL, using imageLoader: ImageLoading, placeholder: UIImage? = nil) -> AdyenCancellable {
        imageLoader.load(url: url) { [weak self] image in
            guard let image else {
                self?.image = placeholder
                return
            }

            self?.image = image
        }
    }
}
