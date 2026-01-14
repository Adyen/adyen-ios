//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import CoreImage

class CardImageParsingMock: CardImageParsing {
    // MARK: - parse

    var parseCallsCount = 0
    var parseCalled: Bool {
        parseCallsCount > 0
    }

    var parseReceivedImage: CIImage?
    var parseReceivedInvocations: [CIImage] = []
    var parseClosure: ((CIImage, @escaping (CreditCard) -> Void) -> Void)?

    func parse(image: CIImage, completion: @escaping (CreditCard) -> Void) {
        parseCallsCount += 1
        parseReceivedImage = image
        parseReceivedInvocations.append(image)
        parseClosure?(image, completion)
    }
}
