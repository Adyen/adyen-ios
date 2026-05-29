//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenUI
import Testing
import UIKit

struct AdyenUIAssetsAccessTests {
    @Test("Images", arguments: [UIImage.adyenLock, UIImage.systemLock])
    func verifyImages(image: UIImage?) {
        #expect(image != nil)
    }
}
