//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

import UIKit

@_spi(AdyenInternal)
extension AdyenDependencyValues {
    public var imageLoader: ImageLoading {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self] = newValue }
    }
}

internal enum ImageLoaderKey: AdyenDependencyKey {
    internal static let liveValue: ImageLoading = ImageLoader()
}
