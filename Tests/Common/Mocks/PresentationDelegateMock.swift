//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenDropIn
import Foundation
import XCTest

final class PresentationDelegateMock: NavigationDelegate {

    var doDismiss: (((() -> Void)?) -> Void)?

    func dismiss(completion: (() -> Void)?) {
        doDismiss?(completion)
    }

    // MARK: - presentComponent

    var presentComponentCallsCount = 0
    var presentComponentCalled: Bool {
        presentComponentCallsCount > 0
    }

    var presentComponentReceivedViewController: UIViewController?
    var doPresent: ((_ viewController: UIViewController) throws -> Void)?

    func present(viewController: UIViewController) {
        presentComponentCallsCount += 1
        presentComponentReceivedViewController = viewController
        
        do {
            try doPresent?(viewController)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
