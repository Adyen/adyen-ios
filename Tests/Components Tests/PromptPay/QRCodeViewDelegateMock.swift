//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions

final class QRCodeViewDelegateMock: QRCodeViewDelegate {

    var saveAsImageCallsCount = 0

    var saveAsImageCalled: Bool {
        saveAsImageCallsCount > 0
    }

    func saveAsImage(qrCodeImage: UIImage?, sourceView: UIView) {
        saveAsImageCallsCount += 1
    }

}
