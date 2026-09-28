//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@testable import AdyenDropIn
import Foundation
import XCTest

final class ActionPresentationDelegateMock: ActionPresentationDelegate {

    // MARK: - presentComponent

    var presentComponentCallsCount = 0
    var presentComponentCalled: Bool {
        presentComponentCallsCount > 0
    }

    var presentComponentReceivedViewController: UIViewController?
    var presentComponentReceivedActionData: ActionData?
    var doPresent: ((_ viewController: UIViewController) throws -> Void)?

    func present(actionData: ActionData, actionViewController: UIViewController) {
        presentComponentCallsCount += 1
        presentComponentReceivedViewController = actionViewController
        presentComponentReceivedActionData = actionData

        do {
            try doPresent?(actionViewController)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
