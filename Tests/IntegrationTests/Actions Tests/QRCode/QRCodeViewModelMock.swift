//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@testable import AdyenActions
import UIKit
import XCTest

internal final class QRCodeViewModelMock: QRCodeViewModelProtocol {
    
    // MARK: - Properties
    
    var flowType: QRCodeFlowType = .copyCode
    var instructionText: String = "Scan the QR code"
    var amountText: String? = "€10.00"
    var actionButtonTitle: String = "Pay"
    var onCopyButtonTitle: String = "Copied!"
    var qrCodeData: String = "mock-qr-code-data"
    var expiration: AdyenObservable<String?> = AdyenObservable(nil)
    var copyInProgress: AdyenObservable<Bool> = AdyenObservable(false)
    var observedProgress: Progress?
    
    // MARK: - loadLogoImage
    
    private(set) var loadLogoImageCalled = false
    private(set) var loadLogoImageCallsCount = 0
    private(set) var loadLogoImageCompletions: [(UIImage?) -> Void] = []
    
    func loadLogoImage(completion: @escaping (UIImage?) -> Void) {
        loadLogoImageCalled = true
        loadLogoImageCallsCount += 1
        loadLogoImageCompletions.append(completion)
    }
    
    /// Helper to trigger completion manually in tests
    func completeLoadLogoImage(with image: UIImage?, at index: Int = 0) {
        guard loadLogoImageCompletions.indices.contains(index) else { return }
        loadLogoImageCompletions[index](image)
    }
    
    // MARK: - performAction
    
    private(set) var performActionCalled = false
    private(set) var performActionCallsCount = 0
    private(set) var performActionReceivedImage: UIImage?
    private(set) var performActionReceivedFromView: UIView?
    
    func performAction(qrCodeImage: UIImage?, from: UIView) {
        performActionCalled = true
        performActionCallsCount += 1
        performActionReceivedImage = qrCodeImage
        performActionReceivedFromView = from
    }
}
