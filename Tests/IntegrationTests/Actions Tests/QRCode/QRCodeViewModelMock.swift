//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenActions
import UIKit
import XCTest

internal final class QRCodeViewModelMock: QRCodeViewModelProtocol {
    
    // MARK: - Properties
    
    var flowType: QRCodeFlowType = .copyCode
    var instructionText: String = ""
    var amountText: String?
    var actionButtonTitle: String = ""
    var onCopyButtonTitle: String = ""
    var qrCodeData: String = ""
    var expiration: AdyenObservable<String?> = AdyenObservable(nil)
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
    
    // Helper to trigger completion manually in tests
    func completeLoadLogoImage(with image: UIImage?, at index: Int = 0) {
        guard loadLogoImageCompletions.indices.contains(index) else { return }
        loadLogoImageCompletions[index](image)
    }
    
    // MARK: - performAction
    
    private(set) var performActionCalled = false
    private(set) var performActionCallsCount = 0
    private(set) var performActionReceivedImage: UIImage?
    
    func performAction(qrCodeImage: UIImage?) {
        performActionCalled = true
        performActionCallsCount += 1
        performActionReceivedImage = qrCodeImage
    }
}
