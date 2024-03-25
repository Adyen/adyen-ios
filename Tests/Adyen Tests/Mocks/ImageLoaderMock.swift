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
    
    var cancellable: AdyenCancellable = CancellableMock(onCancelHandler: { })
    
    func load(url: URL, completion: @escaping ((UIImage?) -> Void)) -> any AdyenCancellable {
        DispatchQueue.main.async {
            completion(self.imageProvider(url))
        }
        return cancellable
    }
}

extension String {

    func generateImage() -> UIImage? {
        let string = self as NSString
        let size = string.size()

        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.white.setFill()
            context.fill(.init(origin: .zero, size: size))

            string.draw(
                with: .init(origin: .zero, size: size),
                options: [.usesLineFragmentOrigin],
                context: nil
            )
        }
    }
}
