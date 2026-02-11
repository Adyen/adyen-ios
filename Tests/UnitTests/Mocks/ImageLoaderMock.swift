//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
@testable @_spi(AdyenInternal) import Adyen

class ImageLoaderMock: ImageLoading {

    var imageProvider: (URL) -> UIImage? = { url in
        url.absoluteString.generateImage()
    }

    var cancellable: AdyenCancellable = CancellableMock(onCancelHandler: {})
     
    var loadCalled: Bool {
        loadCallsCount > 0
    }

    private(set) var loadCallsCount = 0
    private var completions: [(UIImage?) -> Void] = []
    func load(url: URL, completion: @escaping ((UIImage?) -> Void)) -> any AdyenCancellable {
        loadCallsCount += 1
        completions.append(completion)
        DispatchQueue.main.async {
            completion(self.imageProvider(url))
        }
        return cancellable
    }
}
