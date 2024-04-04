//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen

class ImageLoaderMock: ImageLoading {
    
    var imageProvider: (URL) -> UIImage? = { url in
        url.absoluteString.generateImage()
    }
    
    var cancellable: AdyenCancellable = CancellableMock(onCancelHandler: {})
    
    func load(url: URL, completion: @escaping ((UIImage?) -> Void)) -> any AdyenCancellable {
        DispatchQueue.main.async {
            completion(self.imageProvider(url))
        }
        return cancellable
    }
}
