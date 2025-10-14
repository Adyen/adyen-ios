//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenActions
import UIKit
import XCTest

final class QRCodeViewMock: QRCodeViewProtocol {
    
    // MARK: - QRCodeViewProtocol Properties
    
    var rootView: UIView
    
    // MARK: - Initializer
    
    init(rootView: UIView = UIView()) {
        self.rootView = rootView
    }
    
    // MARK: - QRCodeViewProtocol Methods
    
    private(set) var startCopyAnimationCalled = false
    private(set) var startCopyAnimationCallsCount = 0
    func startCopyAnimation() {
        startCopyAnimationCalled = true
        startCopyAnimationCallsCount += 1
    }
}
