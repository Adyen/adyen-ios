//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import UIKit

class MockAdyenNetworkImageProvider: AdyenNetworkImageProviding {
    required init() {}
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        completion(.init(systemName: "photo"))
    }
}
