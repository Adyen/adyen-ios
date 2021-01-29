//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol AnyVoucherViewControllerProvider: Component {
    func provide(with action: VoucherAction) -> UIViewController
}

internal final class VoucherViewControllerProvider: AnyVoucherViewControllerProvider {
    internal func provide(with action: VoucherAction) -> UIViewController {
        switch action {
        case let .dokuIndomaret(dokuIndomaretAction):
            return VoucherViewController(action: dokuIndomaretAction)
        }
    }
}
