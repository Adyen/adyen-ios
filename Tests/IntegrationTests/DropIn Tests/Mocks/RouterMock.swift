//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenDropIn
import Foundation
import UIKit

class RouterMock: Router {
    var childRouter: Router?
    var rootViewController: UIViewController = .init()
}
