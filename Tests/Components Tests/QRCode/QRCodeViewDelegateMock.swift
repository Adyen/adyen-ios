//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions

final class QRCodeViewDelegateMock: QRCodeViewDelegate {

    var saveAsImageCallsCount = 0
    var copyToPasteboardCount = 0

    var saveAsImageCalled: Bool {
        saveAsImageCallsCount > 0
    }

    var copyToPasteboardCalled: Bool {
        copyToPasteboardCount > 0
    }

    func saveAsImage(qrCodeImage: UIImage?, sourceView: UIView) {
        saveAsImageCallsCount += 1
    }

    func copyToPasteboard(with action: QRCodeAction) {
        copyToPasteboardCount += 1
    }

}
