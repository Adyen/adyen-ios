//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen

class ImageLoaderMock: ImageLoading {
    
    var imageProvider: (URL) -> UIImage? = { url in
        url.absoluteString.generateImage()
    }
    
    var cancellable: AdyenCancellable = CancellableMock(onCancelHandler: {})
    
    var loadCallsCount = 0
    var loadWasCalled: Bool { loadCallsCount > 0 }
    func load(url: URL, completion: @escaping ((UIImage?) -> Void)) -> any AdyenCancellable {
        loadCallsCount += 1
        DispatchQueue.main.async {
            completion(self.imageProvider(url))
        }
        return cancellable
    }
}
