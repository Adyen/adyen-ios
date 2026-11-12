//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import UIKit

class ImageLoaderMock: ImageLoading {

    var imageProvider: (URL) -> UIImage? = { url in
        url.absoluteString.generateImage()
    }

    var cancellable: AdyenCancellable = CancellableMock(onCancelHandler: {})
     
    var loadCalled: Bool {
        loadCallsCount > 0
    }

    private(set) var loadCallsCount = 0
    private var completions: [@MainActor @Sendable (UIImage?) -> Void] = []
    func load(url: URL, completion: @escaping @MainActor @Sendable (UIImage?) -> Void) -> any AdyenCancellable {
        loadCallsCount += 1
        completions.append(completion)
        // Tests call the loader on the main thread; keeps the mock's completion synchronous.
        MainActor.assumeIsolated { completion(self.imageProvider(url)) }
        return cancellable
    }
}
